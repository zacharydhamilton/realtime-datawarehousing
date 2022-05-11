-- # In production you would almost certainly limit the replication user must be on the follower (slave) machine,
-- # to prevent other clients accessing the log from other machines. For example, 'replicator'@'follower.acme.com'.
-- #
-- # However, this grant is equivalent to specifying *any* hosts, which makes this easier since the docker host
-- # is not easily known to the Docker container. But don't do this in production.
CREATE USER 'replicator' IDENTIFIED BY 'replpass';
CREATE USER 'debezium' IDENTIFIED BY 'rt-dwh-c0nflu3nt!';
GRANT REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'replicator';
GRANT SELECT, RELOAD, SHOW DATABASES, REPLICATION SLAVE, REPLICATION CLIENT  ON *.* TO 'debezium';

-- # Create the database that we'll use to populate data and watch the effect in the binlog
CREATE DATABASE customers;
GRANT ALL PRIVILEGES ON customers.* TO 'debezium'@'%';

-- # Switch to this database
USE customers;

-- # Create and populate the customer data table
CREATE TABLE customers (
    id VARCHAR(255) PRIMARY KEY, 
    first_name VARCHAR(255),
    last_name VARCHAR(255),
    email VARCHAR(255),
    phone VARCHAR(255)
);

LOAD DATA INFILE '/data/customers.csv'
INTO TABLE customers
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- # Create and populate the demographic data table
CREATE TABLE demographics (
    id VARCHAR(255) PRIMARY KEY,
    street_address VARCHAR(255),
    state VARCHAR(255),
    zip_code VARCHAR(255),
    country VARCHAR(255),
    country_code VARCHAR(255)
);

LOAD DATA INFILE '/data/demographics.csv'
INTO TABLE demographics
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;