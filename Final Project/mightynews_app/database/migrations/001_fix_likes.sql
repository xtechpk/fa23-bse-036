-- FILE: database/migrations/001_fix_likes.sql

-- 1. Create the LIKES table if it doesn't exist
CREATE TABLE IF NOT EXISTS likes (
    id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(id) ON DELETE CASCADE,
    blog_id VARCHAR(50) REFERENCES blogs(id) ON DELETE CASCADE,
    UNIQUE(user_id, blog_id)
);

-- 2. Reset data to prevent errors
UPDATE blogs SET likes_count = 0;
DELETE FROM likes;

