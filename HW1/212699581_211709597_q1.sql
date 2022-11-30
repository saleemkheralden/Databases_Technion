CREATE TABLE GUIDE (
    id INT PRIMARY KEY,
    name VARCHAR(50),
    bd DATE,
        CHECK (YEAR(bd) < 2000),
    email VARCHAR(50),
        CHECK (email LIKE '_%@_%'),
    experience VARCHAR(11),
        CHECK (experience IN ('experienced', 'beginner')),
    fav_country VARCHAR(50) NOT NULL,
        FOREIGN KEY (fav_country) REFERENCES COUNTRY(name),
);

CREATE TABLE COUNTRY (
    name VARCHAR(50) PRIMARY KEY,
    capital_city VARCHAR(50) UNIQUE,
    formal_lang VARCHAR(50),
);

CREATE TABLE ATTR (
    name VARCHAR(50),
    city_name VARCHAR(50),
        PRIMARY KEY (name, city_name),
    rank NUMERIC(18, 17),
        CHECK (rank BETWEEN 1 AND 5),
    price NUMERIC,
);

CREATE TABLE TRIPS (
    name VARCHAR(50) PRIMARY KEY,
    description VARCHAR(50),
    days INT,
        CHECK (days > 3),
    max_app INT,
    guide INT,
        FOREIGN KEY (guide) REFERENCES GUIDE(id),
--         the constraint that every guide must have
--         at least two trips cant be implemented
--         because to know how many trips a guide have
--         we need to count all the trips that have the same guide
--         and we dont have the functionality for that in the DDL
--         it can be implemented in SQL
);

CREATE TABLE TRIP_ROUTE (
    trip_name VARCHAR(50),
        FOREIGN KEY (trip_name) REFERENCES TRIPS(name),
    attr VARCHAR(50),
        FOREIGN KEY (attr) REFERENCES ATTR(name),
        PRIMARY KEY (trip_name, attr),
    trip_days INT,
        FOREIGN KEY (trip_days) REFERENCES TRIPS(days),
    attr_day INT,
        CHECK (attr_day BETWEEN 1 AND trip_days)

);










