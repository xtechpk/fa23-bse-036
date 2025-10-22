require('dotenv').config();
const express = require('express');
const bcrypt = require('bcrypt');
const { Pool } = require('pg');

const app = express();
app.use(express.json());

// Build PG pool config either from DATABASE_URL or individual PG_* env vars.
const rawDbUrl = process.env.DATABASE_URL;
let pool;
let useInMemory = false;
// in-memory store used when no Postgres configured (for quick local testing)
const _inMemory = {
  users: new Map(), // key: email(lower) -> user obj
  nextId: 2,
};

if (rawDbUrl) {
  // If DATABASE_URL provided, validate it and use as connection string
  try {
    const parsed = new URL(rawDbUrl);
    if (!parsed.protocol.startsWith('postgres')) {
      console.error('FATAL: DATABASE_URL must start with postgres:// or postgresql://');
      process.exit(1);
    }
    // password property exists but can be empty string; ensure non-empty
    if (!parsed.password) {
      console.error('FATAL: DATABASE_URL is missing the password. Ensure it has the form postgres://user:password@host:port/db');
      process.exit(1);
    }
  } catch (err) {
    console.error('FATAL: DATABASE_URL is malformed:', err.message);
    process.exit(1);
  }
  pool = new Pool({ connectionString: rawDbUrl });
} else {
  // Fallback to individual env vars: PGUSER, PGPASSWORD, PGHOST, PGPORT, PGDATABASE
  const { PGUSER, PGPASSWORD, PGHOST, PGPORT, PGDATABASE } = process.env;
  if (PGUSER && PGPASSWORD && PGHOST && PGDATABASE) {
    const portNum = PGPORT ? Number(PGPORT) : 5432;
    pool = new Pool({ user: PGUSER, password: PGPASSWORD, host: PGHOST, port: portNum, database: PGDATABASE });
  } else {
    console.warn('No Postgres configuration found — falling back to in-memory database for demo/testing. Data will be lost on restart.');
    useInMemory = true;
    // seed a test user (same as earlier)
    _inMemory.users.set('test@example.com', {
      user_id: 1,
      email: 'test@example.com',
      name: 'Test User',
      password_hash: null,
      cumulative_gpa: 3.5,
    });
  }
}

// Helper DB functions that work with either Postgres pool or in-memory store
async function dbFindUserByEmail(email) {
  const e = email?.trim().toLowerCase();
  if (useInMemory) {
    const u = _inMemory.users.get(e);
    return u ? { rows: [u], rowCount: 1 } : { rows: [], rowCount: 0 };
  }
  return pool.query('SELECT user_id, email, name, password_hash, cumulative_gpa FROM users WHERE LOWER(email) = LOWER($1)', [e]);
}

async function dbInsertUser(email, name, passwordHash) {
  if (useInMemory) {
    const id = _inMemory.nextId++;
    const user = { user_id: id, email, name, password_hash: passwordHash, cumulative_gpa: null };
    _inMemory.users.set(email.toLowerCase(), user);
    return { rows: [user] };
  }
  return pool.query('INSERT INTO users (email, name, password_hash) VALUES ($1, $2, $3) RETURNING user_id, email, name, cumulative_gpa', [email, name, passwordHash]);
}

async function dbFindUserById(id) {
  if (useInMemory) {
    for (const u of _inMemory.users.values()) if (u.user_id === Number(id)) return { rows: [u], rowCount: 1 };
    return { rows: [], rowCount: 0 };
  }
  return pool.query('SELECT user_id, email, name, cumulative_gpa FROM users WHERE user_id = $1', [id]);
}

async function dbUpdateName(id, name) {
  if (useInMemory) {
    for (const [k, u] of _inMemory.users) {
      if (u.user_id === Number(id)) {
        u.name = name;
        _inMemory.users.set(k, u);
        return;
      }
    }
    return;
  }
  await pool.query('UPDATE users SET name = $1 WHERE user_id = $2', [name, id]);
}

async function dbUpdateEmail(id, newEmail) {
  if (useInMemory) {
    // find and rekey
    for (const [k, u] of _inMemory.users) {
      if (u.user_id === Number(id)) {
        _inMemory.users.delete(k);
        u.email = newEmail;
        _inMemory.users.set(newEmail.toLowerCase(), u);
        return;
      }
    }
    return;
  }
  await pool.query('UPDATE users SET email = $1 WHERE user_id = $2', [newEmail, id]);
}

async function dbUpdatePassword(id, hash) {
  if (useInMemory) {
    for (const u of _inMemory.users.values()) {
      if (u.user_id === Number(id)) {
        u.password_hash = hash;
        return;
      }
    }
    return;
  }
  await pool.query('UPDATE users SET password_hash = $1 WHERE user_id = $2', [hash, id]);
}
const PORT = process.env.PORT || 3000;

// Simple health check
app.get('/api/v1/health', (req, res) => res.json({ status: 'ok' }));

// Signup
app.post('/api/v1/auth/signup', async (req, res) => {
  try {
    const { name = '', email: rawEmail, password } = req.body;
    const email = rawEmail?.trim().toLowerCase();
    if (!email || !password) return res.status(400).json({ message: 'Email and password required' });

    const exists = await dbFindUserByEmail(email);
    if (exists.rowCount > 0) return res.status(409).json({ message: 'Email already registered' });

    const passwordHash = await bcrypt.hash(password, 12);
    const insert = await dbInsertUser(email, name, passwordHash);

    return res.status(201).json({ data: insert.rows[0] });
  } catch (err) {
    console.error('signup error', err);
    return res.status(500).json({ message: 'Internal server error' });
  }
});

// Login
app.post('/api/v1/auth/login', async (req, res) => {
  try {
    const { email: rawEmail, password } = req.body;
  const email = rawEmail?.trim().toLowerCase();
  const { rows } = await dbFindUserByEmail(email);
  if (!rows.length) return res.status(401).json({ message: 'Invalid credentials' });

  const user = rows[0];
  if (!user.password_hash) return res.status(401).json({ message: 'Invalid credentials' });
  const ok = await bcrypt.compare(password, user.password_hash);
  if (!ok) return res.status(401).json({ message: 'Invalid credentials' });

  delete user.password_hash;
  return res.json({ data: user, token: 'fake_jwt_token' });
  } catch (err) {
    console.error('login error', err);
    return res.status(500).json({ message: 'Internal server error' });
  }
});

// Middleware to mock auth (reads user id from header X-User-Id for simplicity)
async function requireAuth(req, res, next) {
  const userId = req.header('X-User-Id');
  if (!userId) return res.status(401).json({ message: 'Missing X-User-Id header for demo auth' });
  const { rows } = await dbFindUserById(userId);
  if (!rows.length) return res.status(401).json({ message: 'Invalid user' });
  req.user = rows[0];
  next();
}

// Update name
app.put('/api/v1/profile/:id', requireAuth, async (req, res) => {
  try {
  const { id } = req.params;
  const { name } = req.body;
  await dbUpdateName(id, name);
  return res.json({ message: 'Profile updated' });
  } catch (err) {
    console.error('update profile', err);
    return res.status(500).json({ message: 'Internal server error' });
  }
});

// Update email
app.put('/api/v1/profile/:id/email', requireAuth, async (req, res) => {
  try {
  const { id } = req.params;
  const raw = req.body.email;
  const newEmail = raw?.trim().toLowerCase();
  if (!newEmail) return res.status(400).json({ message: 'Email required' });
  // Check for existing email (when using Postgres we rely on a query; for in-memory the helper will be used)
  const exists = await dbFindUserByEmail(newEmail);
  if (exists.rowCount > 0 && String(exists.rows[0].user_id) !== String(id)) return res.status(409).json({ message: 'Email already in use' });
  await dbUpdateEmail(id, newEmail);
  return res.json({ message: 'Email updated' });
  } catch (err) {
    console.error('update email', err);
    return res.status(500).json({ message: 'Internal server error' });
  }
});

// Update password
app.put('/api/v1/profile/:id/password', requireAuth, async (req, res) => {
  try {
  const { id } = req.params;
  const newPassword = req.body.password;
  if (!newPassword) return res.status(400).json({ message: 'Password required' });
  const hash = await bcrypt.hash(newPassword, 12);
  await dbUpdatePassword(id, hash);
  return res.json({ message: 'Password updated' });
  } catch (err) {
    console.error('update password', err);
    return res.status(500).json({ message: 'Internal server error' });
  }
});

app.listen(PORT, () => console.log(`Backend listening on port ${PORT}`));
