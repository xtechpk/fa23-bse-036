# CGPA App Backend (minimal)

This folder contains a minimal Node.js + Express backend to test signup/login/profile functionality.

Requirements
- Node.js 18+ (or compatible)
- PostgreSQL running with the `cgpa` database and `users` table (see schema in project root)

Quick start
1. Copy `.env.example` to `.env` and edit `DATABASE_URL` to match your Postgres.
2. Install dependencies:
   ```bash
   cd backend
   npm install
   ```
3. Start the server:
   ```bash
   npm run dev
   ```
4. Server will run on `http://localhost:3000` by default.

Endpoints
- GET /api/v1/health — health check
- POST /api/v1/auth/signup — body: { name, email, password }
- POST /api/v1/auth/login — body: { email, password }
- PUT /api/v1/profile/:id — body: { name } — requires header `X-User-Id` for demo auth
- PUT /api/v1/profile/:id/email — body: { email } — requires header `X-User-Id`
- PUT /api/v1/profile/:id/password — body: { password } — requires header `X-User-Id`

Notes
- This is a minimal demo. It uses bcrypt for password hashing and parameterized SQL queries.
- For production you'd use proper authentication (JWT/session), HTTPS, and better error handling.
