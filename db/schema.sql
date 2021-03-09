CREATE DATABASE bitfolio;

CREATE TABLE trades (
    id SERIAL PRIMARY KEY,
    trade_date DATE,
    trade_type TEXT,
    amount DECIMAL(16,8),
    price DECIMAL (16,2),
    total DECIMAL (16,2),
    user_id INTEGER
);


CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    email TEXT,
    password_digest TEXT
);
