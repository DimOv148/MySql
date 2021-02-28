-- Составьте список пользователей users, которые осуществили хотя бы один заказ orders в интернет магазине.

-- внесем данные в таблицу
INSERT INTO orders (user_id) VALUES (1),(2),(3),(4),(2),(3),(6),(1),(3),(4); 

-- вложенным запросом
SELECT name FROM users WHERE id IN (SELECT user_id FROM orders);

-- через Join
SELECT users.name FROM users, orders WHERE users.id = orders.user_id GROUP BY user_id;


-- Выведите список товаров products и разделов catalogs, который соответствует товару.
SELECT products.name, catalogs.name FROM products JOIN catalogs ON products.catalog_id = catalogs.id;

-- Пусть имеется таблица рейсов flights (id, from, to) и таблица городов cities (label, name).
--  Поля from, to и label содержат английские названия городов, поле name — русское. 
-- Выведите список рейсов flights с русскими названиями городов.

DROP TABLE IF EXISTS flights;
CREATE TABLE flights ( 
id SERIAL PRIMARY KEY,
`from` VARCHAR (255) NOT NULL,  
`to` VARCHAR (255) NOT NULL);

INSERT INTO flights (`from`, `to`) VALUES
('moscow', 'omsk'),
('novgorod', 'kazan'),
('irkutsk', 'moscow'),
('omsk', 'irkutsk'),
('moscow', 'kazan');

DROP TABLE IF EXISTS cities;
CREATE TABLE cities (
id SERIAL PRIMARY KEY,
label VARCHAR (255) NOT NULL,  
name VARCHAR (255) NOT NULL);

INSERT INTO cities (label, name) VALUES
('moscow', 'Москва'),
('irkutsk', 'Иркутск'),
('novgorod', 'Новгород'),
('kazan', 'Казань'),
('omsk', 'Омск');


SELECT
	flights.id,
	rus1.name AS `from`,
	rus2.name AS `to`
FROM
	flights
LEFT JOIN cities AS rus1 ON
	rus1.label = `from`
LEFT JOIN cities AS rus2 ON
	rus2.label = `to`;