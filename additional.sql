-- Дополнительные задания:
-- 1. Создать таблицу скидок и дать скидку самым частым клиентам
CREATE TABLE discounts (
    id SERIAL PRIMARY KEY,
    client_id INTEGER,
    percentage INTEGER,
    FOREIGN KEY (client_id) REFERENCES clients(id)
);

INSERT INTO discounts (client_id, percentage)
SELECT
    best_clients.client_id,
    17 -- укажем скидку в 17% (вариант моего задания)
FROM
    (
        SELECT client_id, COUNT(id) as order_count
        FROM orders
        GROUP BY client_id
        ORDER BY order_count DESC
        LIMIT 26 --  всего сервис посетило 524 клиента, выберем 5 процентов базы 
    ) AS best_clients;


-- 2. Поднять зарплату трем самым результативным механикам на 10%
UPDATE workers
SET wages = wages * 1.10
WHERE id IN (
    SELECT worker_id
    FROM orders
    GROUP BY worker_id
    ORDER BY sum(payment) DESC
    LIMIT 3
);


-- 3. Сделать представление для директора: филиал, количество заказов за последний месяц, заработанная сумма, заработанная сумма за вычетом зарплаты
CREATE VIEW month_record AS (
	SELECT
	    s.service as region,
	    s.service_addr as address,
	    COUNT(o.id) AS month_order_count,
	    SUM(o.payment) AS month_income,
	    SUM(o.payment) - SUM(w.wages) AS month_margin
	FROM orders o
	JOIN services s ON o.service_id = s.id
	JOIN workers w ON o.worker_id = w.id
	WHERE o.date >= (SELECT MAX(date) FROM orders) - INTERVAL '1 month' and o.payment is not null
	GROUP by s.id
);


-- 4. Сделать рейтинг самых надежных и ненадежных авто
-- Топ надежных: Chevrolet, Land Rover, BMW
-- Топ НЕнадежных: Mercury, Infiniti, GEM
SELECT c.car, COUNT(o.car_id) AS order_count
FROM cars c
JOIN orders o ON o.car_id = c.id
WHERE payment IS NOT NULL
GROUP BY c.car
ORDER BY order_count

  
-- 5. Самый "удачный" цвет для каждой модели авто
WITH color_order_counts AS (
    SELECT c.car, c.color, COUNT(o.id) AS order_count
    FROM cars c
    LEFT join orders o ON c.id = o.car_id
    GROUP by c.car, c.color
), 
	min_color_order_counts AS (
    SELECT coc.car, MIN(coc.order_count) AS min_color_order_count
    from color_order_counts coc
    GROUP by car
)
SELECT coc.car, coc.color, coc.order_count
FROM color_order_counts coc
join min_color_order_counts mcoc ON coc.car = mcoc.car AND coc.order_count = mcoc.min_color_order_count
ORDER BY coc.car

-- Audi	Амарантовый
-- Audi	Спаржа
-- BMW	Аквамариновый
-- Buick	Античный белый
-- Cadillac	Оранжевый
-- Chevrolet	Спаржа
-- Chrysler	Красный
-- Dodge	Медный
-- Ferrari	Белый
-- Ford	Аквамариновый
-- GEM	Оранжевый
-- GM	Белый
-- GMC	Красный
-- Honda	Аквамариновый
-- Hummer	Фиолетовый
-- Hyundai	Фиолетовый
-- Infiniti	Синий
-- Isuzu	Коричный
-- Jaguar	Медный
-- Jeep	Спаржа
-- Kia	Синий
-- Lamborghini	Сливовый
-- Land Rover	Розовый
-- Lexus	Синий
-- Lincoln	Бистр
-- Lotus	Сливовый
-- Mazda	Сливовый
-- Mercedes-Benz	Белый
-- Mercury	Сливовый
-- Mitsubishi	Медный
-- Nissan	Амарантовый
-- Oldsmobile	Розовый
-- Peugeot	Спаржа
-- Pontiac	Бистр
-- Porsche	Янтарный
-- Regal	Красный
-- Saab	Голубой
-- Saturn	Аметистовый
-- Subaru	Зеленый
-- Suzuki	Спаржа
-- Toyota	Амарантовый
-- Volkswagen	Черный
-- Volkswagen	Хаки
-- Volvo	Античный белый

-- Чаще всего встречается "Спаржа" =)

