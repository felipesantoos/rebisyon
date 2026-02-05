-- Create test database
CREATE DATABASE rebisyon_test;

-- Grant all privileges
GRANT ALL PRIVILEGES ON DATABASE rebisyon_development TO rebisyon;
GRANT ALL PRIVILEGES ON DATABASE rebisyon_test TO rebisyon;

-- Connect to development database and enable extensions
\c rebisyon_development
CREATE EXTENSION IF NOT EXISTS unaccent;

-- Connect to test database and enable extensions
\c rebisyon_test
CREATE EXTENSION IF NOT EXISTS unaccent;
