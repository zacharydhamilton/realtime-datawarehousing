ALTER SYSTEM SET max_wal_senders = '250';
ALTER SYSTEM SET wal_sender_timeout = '60s';
ALTER SYSTEM SET max_replication_slots = '250';
ALTER SYSTEM SET wal_level = 'logical';

CREATE SCHEMA products;
SET search_path TO products;

CREATE EXTENSION postgis;

-- # create and populate products data table
CREATE TABLE products (
	product_id VARCHAR(255) PRIMARY KEY,
    size VARCHAR(255),
    product VARCHAR(255),
    department VARCHAR(255),
    price VARCHAR(255)
);

COPY products(product_id, size, product, department, price)
FROM '/data/products.csv'
DELIMITER ','
CSV HEADER;

-- # create and populate customers data table
CREATE TABLE customers (
    id VARCHAR(255) PRIMARY KEY, 
    first_name VARCHAR(255),
    last_name VARCHAR(255),
    email VARCHAR(255),
    phone VARCHAR(255)
);

COPY customers(id, first_name, last_name, email, phone)
FROM '/data/customers.csv'
DELIMITER ','
CSV HEADER;

-- # create orders table which data will be generated to over time
CREATE TABLE orders (
    order_id VARCHAR(255) PRIMARY KEY,
    product_id VARCHAR(255),
    customer_id VARCHAR(255)
);

CREATE PROCEDURE generate_orders() AS $$
BEGIN
    WHILE 1 = 1 LOOP
        DECLARE 
            product products.products%ROWTYPE;
            customer products.customers%ROWTYPE;
            uuid VARCHAR;
        BEGIN
            SELECT * INTO product FROM products.products ORDER BY random() LIMIT 1; 
            SELECT * INTO customer FROM products.customers ORDER BY random() LIMIT 1;
            SELECT uuid_in(md5(random()::text || clock_timestamp()::text)::cstring) INTO uuid;
            RAISE NOTICE 'values are product % customer % and order %', product.product_id, customer.id, uuid;
            INSERT INTO products.orders (order_id, product_id, customer_id) VALUES (uuid, product.product_id, customer.id);
            COMMIT;
            PERFORM pg_sleep(1);
        END;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- COMMIT;