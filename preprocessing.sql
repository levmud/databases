-- Создаем таблицу car_service, перечисляя названия столбцов и их типы
CREATE TABLE car_service (
    date DATE,
    service TEXT,
    service_addr TEXT,
    w_name TEXT,
    w_exp TEXT,
    w_phone TEXT,
    wages INTEGER,
    card TEXT,
    payment TEXT,
    pin TEXT,
    name TEXT,
    phone TEXT,
    email TEXT,
    password TEXT,
    car TEXT,
    mileage INTEGER,
    vin TEXT,
    car_number TEXT,
    color TEXT
);

-- Восстановление пропусков по столбцам - СОТРУДНИКИ
-- Имена сотрудников по номеру телефона - убедиться, что номер телефона не переходил между сотрудниками / сотрудники не пользуются рабочим (общим) номером
select w_phone, count(distinct w_name) count_w_name
from car_service cs 
group by w_phone
  
-- Обновление ФИ сотрудников по номеру телефона
UPDATE car_service AS cs
SET cs.w_name = workers.w_name
FROM (
	SELECT distinct w_name, w_phone
	FROM car_service
	WHERE w_name IS NOT NULL AND w_phone IS NOT NULL
	) AS workers
WHERE cs.w_phone = workers.w_phone;

-- Обновление зарплаты сотрудников по номеру телефона
UPDATE car_service AS cs
SET wages = workers.wages
FROM (
	SELECT distinct wages, w_phone
	FROM car_service
	WHERE wages IS NOT NULL AND w_phone IS NOT NULL
	) AS workers
WHERE cs.w_phone = workers.w_phone;

-- Обновление опыта сотрудников по номеру телефона
UPDATE car_service AS cs
SET w_exp = workers.w_exp
FROM (
	SELECT distinct w_exp, w_phone
	FROM car_service
	WHERE w_exp IS NOT NULL AND w_phone IS NOT NULL
	) AS workers
WHERE cs.w_phone = workers.w_phone;

-- Обновление номеров сотрудников по другим параметрам
UPDATE car_service AS cs
SET w_phone = workers.w_phone
FROM (
    SELECT distinct wages, w_name, w_exp, w_phone
    FROM car_service
    WHERE w_name IS NOT NULL AND w_exp IS NOT NULL AND wages IS NOT NULL AND w_phone IS NOT NULL
) AS workers
WHERE cs.w_name = workers.w_name AND cs.w_exp = workers.w_exp AND cs.wages = workers.wages;


-- Восстановление пропусков по столбцам - СЕРВИСЫ
-- Уникальные области по номеру телефона сотрудника - получаем, что сотрудник работает только в одном сервисе
select w_phone, count(distinct(service)),  count(distinct(service_addr))
from car_service cs 
group by w_phone 

-- Обновление областей сервисов по номеру телефона сотрудника
UPDATE car_service AS cs
SET service = workers.service
FROM (
    SELECT distinct service, w_phone
    FROM car_service
    WHERE service IS NOT NULL AND w_phone IS NOT NULL
) AS workers
WHERE cs.w_phone = workers.w_phone;

-- Обновление адресов сервисов по номеру телефона сотрудника
UPDATE car_service AS cs
SET service_addr = workers.service_addr
FROM (
    SELECT distinct service_addr, w_phone
    FROM car_service
    WHERE service_addr IS NOT NULL AND w_phone IS NOT NULL
) AS workers
WHERE cs.w_phone = workers.w_phone;

-- Восстановление пропусков по столбцам - КЛИЕНТЫ
-- Обновление ФИ клиента по номеру телефона
UPDATE car_service AS cs
SET name = clients.name
FROM (
	SELECT distinct name, phone
	FROM car_service
	WHERE name IS NOT NULL and phone IS NOT NULL
	) AS clients
WHERE cs.phone = clients.phone;

-- Обновление email клиента по номеру телефона
UPDATE car_service AS cs
SET email = clients.email
FROM (
	SELECT distinct email, phone
	FROM car_service
	WHERE email IS NOT NULL and phone IS NOT NULL
	) AS clients
WHERE cs.phone = clients.phone;

-- Обновление телефона клиента по email
UPDATE car_service AS cs
SET phone = clients.phone
FROM (
	SELECT distinct email, phone
	FROM car_service
	WHERE email IS NOT NULL and phone IS NOT NULL
	) AS clients
WHERE cs.email = clients.email;

-- Обновление пароля клиента по email
UPDATE car_service AS cs
SET password = clients.password
FROM (
	SELECT distinct email, password
	FROM car_service
	WHERE email IS NOT NULL and password IS NOT NULL
	) AS clients
WHERE cs.email = clients.email;


-- Восстановление пропусков по столбцам - МАШИНЫ
-- Обновление номера машины по vin
UPDATE car_service AS cs
SET car_number = cars.car_number
FROM (
    SELECT distinct car_number, vin
    FROM car_service
    where car_number IS NOT NULL and vin IS NOT NULL
	) AS cars
WHERE cs.vin = cars.vin;

-- Обновление марки машины по vin
UPDATE car_service AS cs
SET car = cars.car
FROM (
    SELECT distinct car, vin
    FROM car_service
    where car IS NOT NULL and vin IS NOT NULL
	) AS cars
WHERE cs.vin = cars.vin;

-- Обновление цвета машины по vin
UPDATE car_service AS cs
SET color = cars.color
FROM (
    SELECT distinct color, vin
    FROM car_service
    where color IS NOT NULL and vin IS NOT NULL
	) AS cars
WHERE cs.vin = cars.vin;

-- Нельзя четко сказать вин по номеру
select car_number , count(distinct(vin)) vins
FROM car_service
group by car_number 

-- Можно точно сказать вин по набору параметров
select car_number, car, color, count(distinct(vin)) vins
FROM car_service
group by car_number, car, color

-- Обновление vin машины по номеру, марке и цвету
UPDATE car_service AS cs
SET vin = cars.vin
FROM (
    SELECT distinct car_number, car, color, vin
    FROM car_service
    where car IS NOT NULL and car_number IS NOT NULL and color IS NOT NULL and vin IS NOT NULL
	) AS cars
where 
    cs.car_number = cars.car_number AND
    cs.car = cars.car AND
    cs.color = cars.color;

-- Нельзя восстановить пробег автомобиля, так как он меняется и не зависит от чего-то
-- Нельзя восстановить номер карты, сумму оплаты и pin, так как нет зависимости от других полей
