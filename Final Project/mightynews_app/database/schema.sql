-- FILE: database/schema.sql
-- MASTER SCHEMA (v3.0)

-- 1. USERS TABLE
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(20) DEFAULT 'user', -- 'admin' or 'user'
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. CATEGORIES TABLE
CREATE TABLE IF NOT EXISTS categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL
);

-- 3. BLOGS TABLE
CREATE TABLE IF NOT EXISTS blogs (
    id VARCHAR(50) PRIMARY KEY,
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    author VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    category VARCHAR(50) REFERENCES categories(name) ON DELETE SET NULL,
    image_path TEXT,
    likes_count INT DEFAULT 0
);

-- 4. LIKES TABLE (New Feature: 1 Like Per User)
CREATE TABLE IF NOT EXISTS likes (
    id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(id) ON DELETE CASCADE,
    blog_id VARCHAR(50) REFERENCES blogs(id) ON DELETE CASCADE,
    UNIQUE(user_id, blog_id) -- Prevents duplicate likes
);

-- 5. BOOKMARKS TABLE
CREATE TABLE IF NOT EXISTS bookmarks (
    id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(id) ON DELETE CASCADE,
    blog_id VARCHAR(50) REFERENCES blogs(id) ON DELETE CASCADE,
    UNIQUE(user_id, blog_id)
);

-- 6. COMMENTS TABLE
CREATE TABLE IF NOT EXISTS comments (
    id SERIAL PRIMARY KEY,
    blog_id VARCHAR(50) REFERENCES blogs(id) ON DELETE CASCADE,
    username VARCHAR(50) NOT NULL,
    text TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 7. SUPPORT TICKETS TABLE
CREATE TABLE IF NOT EXISTS support_tickets (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    subject VARCHAR(100) NOT NULL,
    message TEXT NOT NULL,
    status VARCHAR(20) DEFAULT 'open',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 8. SEED DATA (Default Logins)
INSERT INTO users (username, password, role) 
VALUES ('admin', 'admin123', 'admin') 
ON CONFLICT (username) DO NOTHING;

INSERT INTO users (username, password, role) 
VALUES ('user', 'user123', 'user') 
ON CONFLICT (username) DO NOTHING;

INSERT INTO categories (name) 
VALUES ('Technology'), ('Business'), ('Health'), ('Design'), ('Sports'), ('World') 
ON CONFLICT (name) DO NOTHING;