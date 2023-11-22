--  1) Вывести к каждому самолету класс обслуживания и количество мест этого класса
SELECT model, fare_conditions, COUNT(seat_no) as count_seats
FROM aircrafts_data ad
         INNER JOIN seats s ON ad.aircraft_code = s.aircraft_code
GROUP BY model, fare_conditions
ORDER BY model, fare_conditions;

--  2) Найти 3 самых вместительных самолета (модель + кол-во мест)
SELECT model, COUNT(seat_no) as count_seats
FROM aircrafts_data ad
         INNER JOIN seats s ON ad.aircraft_code = s.aircraft_code
GROUP BY model
ORDER BY count_seats DESC LIMIT 3;

-- 3) Найти все рейсы, которые задерживались более 2 часов
SELECT *
FROM flights
WHERE actual_departure > scheduled_departure + INTERVAL '2 hours';

-- 4) Найти последние 10 билетов, купленные в бизнес-классе (fare_conditions = 'Business'), с указанием имени пассажира и контактных данных
SELECT t.ticket_no, t.passenger_name, t.contact_data
FROM tickets t
         INNER JOIN ticket_flights tf ON t.ticket_no=tf.ticket_no
WHERE tf.fare_conditions='Business'
ORDER BY t.book_ref DESC LIMIT 10

-- 5) Найти все рейсы, у которых нет забронированных мест в бизнес-классе (fare_conditions = 'Business')
SELECT *
FROM flights f
WHERE NOT EXISTS (
    SELECT 1
    FROM boarding_passes bp
             INNER JOIN seats s ON bp.seat_no = s.seat_no AND f.aircraft_code = s.aircraft_code
    WHERE bp.flight_id = f.flight_id AND s.fare_conditions = 'Business'
);

-- 6) Получить список аэропортов (airport_name) и городов (city), в которых есть рейсы с задержкой
SELECT DISTINCT ad.airport_name, ad.city
FROM flights f
         INNER JOIN airports_data ad ON f.departure_airport = ad.airport_code
WHERE f.status = 'Delayed'
ORDER BY ad.city;

-- 7) Получить список аэропортов (airport_name) и количество рейсов, вылетающих из каждого аэропорта, отсортированный по убыванию количества рейсов
SELECT ad.airport_name, COUNT(f.flight_id) AS flights_count
FROM airports_data ad
         LEFT JOIN flights f ON ad.airport_code = f.departure_airport
GROUP BY ad.airport_name
ORDER BY flights_count DESC;

-- 8) Найти все рейсы, у которых запланированное время прибытия (scheduled_arrival) было изменено и новое время прибытия (actual_arrival) не совпадает с запланированным
SELECT *
FROM flights f
WHERE f.scheduled_arrival != f.actual_arrival

-- 9) Вывести код, модель самолета и места не эконом класса для самолета "Аэробус A321-200" с сортировкой по местам
SELECT a.aircraft_code, a.model, s.seat_no
FROM aircrafts a
         INNER JOIN seats s ON a.aircraft_code=s.aircraft_code
WHERE a.model='Аэробус A321-200' AND s.fare_conditions!='Economy'
ORDER BY s.seat_no

-- 10) Вывести города, в которых больше 1 аэропорта (код аэропорта, аэропорт, город)
SELECT ad.airport_code, ad.airport_name, ad.city
FROM airports_data ad
WHERE ad.city IN (
    SELECT ad1.city
    FROM airports_data ad1
    GROUP BY ad1.city
    HAVING COUNT(*) > 1
)

-- 11) Найти пассажиров, у которых суммарная стоимость бронирований превышает среднюю сумму всех бронирований
SELECT t.passenger_id, t.passenger_name, t.contact_data
FROM tickets t
         INNER JOIN bookings b ON t.book_ref=b.book_ref
GROUP BY t.passenger_id, t.passenger_name, t.contact_data
HAVING SUM(b.total_amount) > (SELECT AVG(b1.total_amount) FROM bookings b1)

-- 12) Найти ближайший вылетающий рейс из Екатеринбурга в Москву, на который еще не завершилась регистрация
SELECT *
FROM flights_v
WHERE departure_city = 'Екатеринбург' AND arrival_city = 'Москва' AND status in ('Scheduled', 'On Time', 'Delayed')
ORDER BY scheduled_departure LIMIT 1;

-- 13) Вывести самый дешевый и дорогой билет и стоимость (в одном результирующем ответе)
(SELECT *
 FROM ticket_flights
 ORDER BY amount LIMIT 1)
UNION
(SELECT *
 FROM ticket_flights
 ORDER BY amount DESC LIMIT 1);

-- 14) Написать DDL таблицы Customers, должны быть поля id, firstName, LastName, email, phone. Добавить ограничения на поля (constraints)
CREATE TABLE IF NOT EXISTS Customers (
    id SERIAL PRIMARY KEY,
    firstName VARCHAR(40) NOT NULL,
    lastName VARCHAR(43) NOT NULL,
    email VARCHAR(100) CHECK (email ~* '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$') UNIQUE NOT NULL,
    phone VARCHAR(20) CHECK (phone NOT LIKE '%[^0-9]%') NOT NULL
    );

-- 15) Написать DDL таблицы Orders, должен быть id, customerId, quantity. Должен быть внешний ключ на таблицу customers + constraints
CREATE TABLE IF NOT EXISTS Orders (
    id SERIAL PRIMARY KEY,
    customerId INTEGER NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
    quantity INTEGER NOT NULL CHECK(quantity > 0)
    );

-- 16) Написать 5 insert в эти таблицы
INSERT INTO Customers (firstName, lastName, email, phone)
VALUES
    ('Алексей', 'Смирнов', 'alex@mail.ru', '1111111111'),
    ('Елена', 'Иванова', 'elena@gmail.com', '2222222222'),
    ('Павел', 'Кузнецов', 'pavel@yandax.ru', '3333333333'),
    ('Наталья', 'Петрова', 'natalia@spark.com', '4444444444'),
    ('Сергей', 'Сидоров', 'sergey@gsu.by', '5555555555');

INSERT INTO Orders (customerId, quantity)
VALUES
    (3, 1),
    (1, 2),
    (4, 5),
    (2, 4),
    (5, 3);

-- 17) Удалить таблицы
DROP TABLE Customers;
DROP TABLE Orders;