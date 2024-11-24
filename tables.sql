-- Создадим таблицу для хранения информации по сотрудникам
CREATE TABLE workers (
    id SERIAL PRIMARY KEY,
    first_name TEXT,
    last_name TEXT,
    exp INTEGER,
    phone TEXT,
    wages INTEGER
);

INSERT INTO workers(first_name, last_name, exp, phone, wages)
SELECT DISTINCT 
    SPLIT_PART(w_name, ' ', 1) AS first_name,
    SPLIT_PART(w_name, ' ', 2) AS last_name,
    w_exp::INTEGER AS exp,
    w_phone AS phone,
    wages::INTEGER 
FROM car_service;


-- Создадим таблицу для хранения информации по сервисам
CREATE TABLE services (
    id SERIAL PRIMARY KEY,
    service TEXT,
    service_addr TEXT
);

INSERT INTO services(service, service_addr)
SELECT DISTINCT 
    service, 
    service_addr
FROM car_service;


-- Создадим таблицу для хранения информации по rkbtynfv
CREATE TABLE clients (
    id SERIAL PRIMARY KEY,
    first_name TEXT,
    last_name TEXT,
    phone TEXT,
    email TEXT,
    password TEXT
);

INSERT INTO clients (first_name, last_name, phone, email, password)
SELECT DISTINCT
    SPLIT_PART(name, ' ', 1) AS first_name,
    SPLIT_PART(name, ' ', 2) AS last_name,
    phone,
    email,
    password
FROM car_service; 


-- Создадим таблицу для учета машин клиентов
CREATE TABLE cars (
    id SERIAL PRIMARY KEY,
    vin TEXT,
    car TEXT,
    number TEXT,
    color TEXT
);

INSERT INTO cars(vin, car, number, color)
SELECT DISTINCT
    vin,
    car,
    car_number,
    color
FROM car_service;


-- Создадим таблицу для учета заказов
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    date DATE,
    service_id INTEGER,
    worker_id INTEGER,
    card TEXT,
    payment INTEGER,
    pin INTEGER,
    client_id INTEGER,
    car_id INTEGER,
    mileage INTEGER
);

-- Вставка данных в таблицу orders
INSERT INTO orders (date, service_id, worker_id, card, payment, pin, client_id, car_id, mileage)
SELECT
    date,
    s.id,
    w.id,
    card,
    payment::INTEGER,
    pin::INTEGER,
    cl.id,
    c.id,
    mileage::INTEGER
FROM car_service cs
JOIN services s ON cs.service = s.service and cs.service_addr = s.service_addr
JOIN workers w ON cs.w_phone = w.phone
JOIN clients cl ON cs.phone = cl.phone
JOIN cars c ON cs.vin = c.vin;


-- Построение связи между таблицами
ALTER TABLE orders
ADD CONSTRAINT fk_service
FOREIGN KEY (service_id) REFERENCES services(id),
ADD CONSTRAINT fk_worker
FOREIGN KEY (worker_id) REFERENCES workers(id),
ADD CONSTRAINT fk_client
FOREIGN KEY (client_id) REFERENCES clients(id),
ADD CONSTRAINT fk_car
FOREIGN KEY (car_id) REFERENCES cars(id);

-- Добавление индексов хотя бы одному столбцу таблицы
CREATE INDEX orders_date_idx ON orders(date);
CREATE INDEX services_region_idx ON services(service);
CREATE INDEX workers_phone_idx ON workers(phone);
CREATE INDEX clients_phone_idx ON clients(phone);
CREATE INDEX cars_number_idx ON cars(number);

