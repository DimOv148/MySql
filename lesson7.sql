-- ��������� ������ ������������� users, ������� ����������� ���� �� ���� ����� orders � �������� ��������.

-- ������ ������ � �������
INSERT INTO orders (user_id) VALUES (1),(2),(3),(4),(2),(3),(6),(1),(3),(4); 

-- ��������� ��������
SELECT name FROM users WHERE id IN (SELECT user_id FROM orders);

-- ����� Join
SELECT users.name FROM users, orders WHERE users.id = orders.user_id GROUP BY user_id;


-- �������� ������ ������� products � �������� catalogs, ������� ������������� ������.
SELECT products.name, catalogs.name FROM products JOIN catalogs ON products.catalog_id = catalogs.id;

-- ����� ������� ������� ������ flights (id, from, to) � ������� ������� cities (label, name).
--  ���� from, to � label �������� ���������� �������� �������, ���� name � �������. 
-- �������� ������ ������ flights � �������� ���������� �������.

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
('moscow', '������'),
('irkutsk', '�������'),
('novgorod', '��������'),
('kazan', '������'),
('omsk', '����');


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