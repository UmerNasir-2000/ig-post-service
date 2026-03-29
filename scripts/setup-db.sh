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
CREATE TABLE posts (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255),
    content TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO posts (title, content) VALUES
('First Post', 'Hello from inline SQL'),
('Second Post', 'No files needed!');
EOF

echo "Database ready 🚀"
echo "psql -U ig-post-user -d ig-post-db"
