#!/bin/bash

CONTAINER_NAME=postgres-db

echo "Removing old container..."
docker rm -f $CONTAINER_NAME 2>/dev/null

echo "Starting PostgreSQL..."

docker run -d \
  --name $CONTAINER_NAME \
  -e POSTGRES_USER=ig-post-user \
  -e POSTGRES_PASSWORD=post-password \
  -e POSTGRES_DB=ig-post-db \
  -p 3001:5432 \
  postgres:alpine

echo "Waiting for Postgres to be ready..."

# Wait until Postgres is ready
until docker exec $CONTAINER_NAME pg_isready -U ig-post-user > /dev/null 2>&1; do
  sleep 1
done

echo "Seeding database..."

docker exec -i $CONTAINER_NAME psql -U ig-post-user -d ig-post-db <<EOF

-- Enable UUID generation
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Create posts table
CREATE TABLE IF NOT EXISTS posts (
    post_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    post_uuid UUID NOT NULL UNIQUE DEFAULT gen_random_uuid(),

    fk_user_uuid UUID NOT NULL,

    title VARCHAR(214) NOT NULL,

    caption TEXT NOT NULL
        CHECK (char_length(caption) <= 2200),

    visibility VARCHAR(10) NOT NULL
        CHECK (visibility IN ('PUBLIC', 'PRIVATE')),

    like_count INTEGER NOT NULL DEFAULT 0,
    comment_count INTEGER NOT NULL DEFAULT 0,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP
);

-- Insert sample data
INSERT INTO posts (fk_user_uuid, title, caption, visibility)
VALUES
    (gen_random_uuid(), 'First Post', 'Hello from inline SQL', 'PUBLIC'),
    (gen_random_uuid(), 'Second Post', 'No files needed!', 'PUBLIC');

EOF

echo "Database ready 🚀"
echo "psql -U ig-post-user -d ig-post-db"
