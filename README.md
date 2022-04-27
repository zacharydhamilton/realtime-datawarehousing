# PREREQS
- docker
- terraform
- cloud provider account
    - aws
        - api key and secret
    - gcp 
        - project name
        - json key file
- data warehouse
    - snowflake
    - databricks

# CONNECT
### Postgres
#### Connector Props:
Database Hostname: *derived from terraform*
Database Post: 5432
Database Username: postgres
Database Password: postgres
Database Name: postgres
Database Server Name: postgres

Tables Included: products.products, products.orders

Output Kafka Record Value Format: JSON_SR
Tasks: 1

### Mysql
#### Connector Props
Database Hostname: *derived from terraform*
Database Post: 3306
Database Username: debezium
Database Password: debezium
Database Server Name: mysql

Database Included: customers
Tables Included: customers.customers, customers.demographics

Output Kafka Record Value Format: JSON_SR
After-state Only: false
Output Kafka Record Key Format: JSON_SR

# KSQL

```sql
    CREATE STREAM customers_structured (
        struct_key STRUCT<id VARCHAR> KEY,
        before STRUCT<id VARCHAR, first_name VARCHAR, last_name VARCHAR, email VARCHAR, phone VARCHAR>,
        after STRUCT<id VARCHAR, first_name VARCHAR, last_name VARCHAR, email VARCHAR, phone VARCHAR>,
        op VARCHAR
    ) WITH (
        KAFKA_TOPIC='mysql.customers.customers',
        KEY_FORMAT='JSON_SR',
        VALUE_FORMAT='JSON_SR'
    );
```

```sql
    CREATE STREAM customers_flattened AS 
        SELECT
            after->id,
            after->first_name first_name, 
            after->last_name last_name,
            after->email email,
            after->phone phone
        FROM customers_structured
        PARTITION BY after->id
    EMIT CHANGES;
```

```sql
    CREATE TABLE customers AS 
        SELECT
            id,
            LATEST_BY_OFFSET(first_name) first_name, 
            LATEST_BY_OFFSET(last_name) last_name,
            LATEST_BY_OFFSET(email) email,
            LATEST_BY_OFFSET(phone) phone
        FROM customers_flattened
        GROUP BY id
    EMIT CHANGES;
```

```sql
    CREATE STREAM demographics_structured (
        struct_key STRUCT<id VARCHAR> KEY,
        before STRUCT<id VARCHAR, street_address VARCHAR, state VARCHAR, zip_code VARCHAR, country VARCHAR, country_code VARCHAR>,
        after STRUCT<id VARCHAR, street_address VARCHAR, state VARCHAR, zip_code VARCHAR, country VARCHAR, country_code VARCHAR>,
        op VARCHAR
    ) WITH (
        KAFKA_TOPIC='mysql.customers.demographics',
        KEY_FORMAT='JSON_SR',
        VALUE_FORMAT='JSON_SR'
    );
```

```sql
    CREATE STREAM demographics_flattened AS 
        SELECT
            after->id,
            after->street_address,
            after->state,
            after->zip_code,
            after->country,
            after->country_code
        FROM demographics_structured
        PARTITION BY after->id
    EMIT CHANGES;
```

```sql
    CREATE TABLE demographics AS
        SELECT
            id, 
            LATEST_BY_OFFSET(street_address) street_address,
            LATEST_BY_OFFSET(state) state,
            LATEST_BY_OFFSET(zip_code) zip_code,
            LATEST_BY_OFFSET(country) country,
            LATEST_BY_OFFSET(country_code) country_code
        FROM demographics_flattened
        GROUP BY id
    EMIT CHANGES;
```

```sql
    CREATE TABLE customers_enriched AS
        SELECT 
            c.id id, c.first_name first_name, c.last_name last_name, c.email email, c.phone phone,
            d.street_address street_address, d.state state, d.zip_code zip_code, d.country country, d.country_code country_code
        FROM customers c
            JOIN demographics d ON d.id = c.id
    EMIT CHANGES;
```

#--------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------

```sql
    CREATE STREAM products_composite (
        struct_key STRUCT<product_id VARCHAR> KEY,
        product_id VARCHAR,
        `size` VARCHAR,
        product VARCHAR,
        department VARCHAR,
        price VARCHAR,
        __deleted VARCHAR
    ) WITH (
        KAFKA_TOPIC='postgres.products.products',
        KEY_FORMAT='JSON',
        VALUE_FORMAT='JSON_SR'
    );
```

```sql
    CREATE STREAM products_rekeyed AS
        SELECT 
            product_id,
            `size`,
            product,
            department,
            price,
            __deleted deleted
        FROM products_composite
        PARTITION BY product_id
    EMIT CHANGES;
```

```sql 
    CREATE TABLE products AS
        SELECT 
            product_id,
            LATEST_BY_OFFSET(`size`) `size`,
            LATEST_BY_OFFSET(product) product,
            LATEST_BY_OFFSET(department) department,
            LATEST_BY_OFFSET(price) price,
            LATEST_BY_OFFSET(deleted) deleted
        FROM products_rekeyed
        GROUP BY product_id
    EMIT CHANGES;
```

```sql
    CREATE STREAM orders_composite (
        struct_key STRUCT<order_id VARCHAR> KEY,
        order_id VARCHAR,
        product_id VARCHAR,
        customer_id VARCHAR,
        __deleted VARCHAR
    ) WITH (
        KAFKA_TOPIC='postgres.products.orders',
        KEY_FORMAT='JSON',
        VALUE_FORMAT='JSON_SR'
    );
```

```sql
    CREATE STREAM orders_rekeyed AS
        SELECT
            order_id,
            product_id,
            customer_id,
            __deleted deleted
        FROM orders_composite
        PARTITION BY order_id
    EMIT CHANGES;
```

```sql
    CREATE STREAM orders_enriched AS
        SELECT 
            o.order_id order_id,
            p.product_id product_id, p.`size` `size`, p.product product, p.department department, p.price price,
            c.id id, c.first_name first_name, c.last_name last_name, c.email email, c.phone phone,
            c.street_address street_address, c.state state, c.zip_code zip_code, c.country country, c.country_code country_code
        FROM orders_rekeyed o
            JOIN products p ON o.product_id = p.product_id
            JOIN customers_enriched c ON o.customer_id = c.id  
    EMIT CHANGES;  
```