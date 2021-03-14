-- Практическое задание по теме “Оптимизация запросов”
-- Создайте таблицу logs типа Archive. Пусть при каждом создании записи в таблицах users, 
-- catalogs и products в таблицу logs помещается время и дата создания записи, название таблицы, 
-- идентификатор первичного ключа и содержимое поля name.


DROP TABLE IF EXISTS logs;
CREATE TABLE logs (
created_at DATETIME NOT NULL,
tabs_name VARCHAR (32) NOT NULL,
tabs_id INT NOT NULL,
field_name VARCHAR (32) NOT NULL)
ENGINE = ARCHIVE;


DROP TRIGGER IF EXISTS change_users;
DELIMITER //
CREATE TRIGGER change_users AFTER INSERT ON users
FOR EACH ROW
BEGIN
  INSERT INTO logs (created_at, tabs_name, tabs_id, field_name)
  VALUES (NOW(), 'users', NEW.id, NEW.name);
END//
DELIMITER ;

INSERT INTO users (name, birthday_at) VALUES ('Василий', '1973-10-15'), ('Виктория', '1982-02-12');
SELECT * FROM users;
SELECT * FROM logs;

DROP TRIGGER IF EXISTS change_catalogs;
DELIMITER //
CREATE TRIGGER change_catalogs AFTER INSERT ON catalogs
FOR EACH ROW
BEGIN
  INSERT INTO logs (created_at, tabs_name, tabs_id, field_name)
  VALUES (NOW(), 'catalogs', NEW.id, NEW.name);
END//
DELIMITER ;

INSERT INTO catalogs (name) VALUES ('Мониторы'), ('Клавиатуры'), ('Колонки');
SELECT * FROM catalogs;
SELECT * FROM logs;

DROP TRIGGER IF EXISTS change_products;
DELIMITER //
CREATE TRIGGER change_products AFTER INSERT ON products
FOR EACH ROW
BEGIN
  INSERT INTO logs (created_at, tabs_name, tabs_id, field_name)
  VALUES (NOW(), 'products', NEW.id, NEW.name);
END//
DELIMITER ;

INSERT INTO products (name, price, catalog_id) VALUES 
('Samsung C24RG50FQI 23.5', '13849', '6'), 
('LG 27GN800-B-27  ', '26284', '6'),
('HP 434820-257', '950', '7'),
('MSI VIGOR G50', '6495', '7'),
('Creative Stage', '8950', '8'),
('Microlab FC 530U', '8190', '8');

SELECT * FROM products;
SELECT * FROM logs;

-- 2. (по желанию) Создайте SQL-запрос, который помещает в таблицу users миллион записей.
-- Сделал на 10000 записей, т.к. 1 млн. записей буде выполняться очень долго.

CREATE TABLE IF NOT EXISTS users_new (
  id SERIAL,
  name VARCHAR(255),
  birthday DATE
);

SELECT * FROM users_new;

DROP PROCEDURE IF EXISTS insert_users_new;
DELIMITER //
CREATE PROCEDURE insert_users_new()
BEGIN 
	DECLARE n int default 10000;
	WHILE n > 0 do
	INSERT INTO users_new (name, birthday) VALUES ((CONCAT(CHAR(FLOOR(RAND()*(90-65)+65)), CHAR(FLOOR(RAND()*(122-97)+97)), CHAR(FLOOR(RAND()*(122-97)+97)),
	CHAR(FLOOR(RAND()*(122-97)+97)), CHAR(FLOOR(RAND()*(122-97)+97)), ' ',
	CHAR(FLOOR(RAND()*(90-65)+65)), CHAR(FLOOR(RAND()*(122-97)+97)), CHAR(FLOOR(RAND()*(122-97)+97)),
	CHAR(FLOOR(RAND()*(122-97)+97)), CHAR(FLOOR(RAND()*(122-97)+97)))), (CURDATE() - INTERVAL floor(RAND() * 45) year));
	SET n = n - 1;
	END WHILE; 
END //

CALL insert_users_new;

SELECT * FROM users_new;


-- Практическое задание по теме “NoSQL”
-- 1. В базе данных Redis подберите коллекцию для подсчета посещений с определенных IP-адресов.

127.0.0.1:6379> sadd ip 192.168.1.15 192.168.16 192.168.1.20 192.168.1.30
(integer) 4
127.0.0.1:6379> sadd ip 192.168.1.15
(integer) 0
127.0.0.1:6379> smembers ip
1) "192.168.16"
2) "192.168.1.30"
3) "192.168.1.20"
4) "192.168.1.15"
127.0.0.1:6379> scard ip
(integer) 4
127.0.0.1:6379> 

-- 2. При помощи базы данных Redis решите задачу поиска имени пользователя по электронному адресу
-- и наоборот, поиск электронного адреса пользователя по его имени.

dim@dim-VirtualBox:~$ redis-cli
127.0.0.1:6379> mset tim iim@mail.ru tim@mail.ru tim
OK
127.0.0.1:6379> get tim
"iim@mail.ru"
127.0.0.1:6379> get tim@mail.ru
"tim"
127.0.0.1:6379> 

-- 3. Организуйте хранение категорий и товарных позиций учебной базы данных shop в СУБД MongoDB.

> use catalogs
> db.catalogs.insertMany([
... {"name": "Processor"},
... {"name": "Motherboards"},
... {"name": "Monitors"},
... {"name": "HDD"}])
{
	"acknowledged" : true,
	"insertedIds" : [
		ObjectId("604e0cec98bef055dfaaf1d8"),
		ObjectId("604e0cec98bef055dfaaf1d9"),
		ObjectId("604e0cec98bef055dfaaf1da"),
		ObjectId("604e0cec98bef055dfaaf1db")
	]
}
> db.catalogs.count()
4
> db.catalogs.find().pretty()
{ "_id" : ObjectId("604e0cec98bef055dfaaf1d8"), "name" : "Processor" }
{ "_id" : ObjectId("604e0cec98bef055dfaaf1d9"), "name" : "Motherboards" }
{ "_id" : ObjectId("604e0cec98bef055dfaaf1da"), "name" : "Monitors" }
{ "_id" : ObjectId("604e0cec98bef055dfaaf1db"), "name" : "HDD" }
> use products
switched to db products
> db.products.insertMany([
... {"name": "Intel Core i5 7400", "description": "Desctop processor", "price": "12700", "catalog_id": "1", "created_at": new Date(), "updated_at": new Date()}, {"name": "Asus ROG Maximus", "description": "Laptop motherboard", "price": "19310", "catalog_id": "2", "created_at": new Date(), "updated_at": new Date()},{"name": "Samsung C24R", "description": "Monitor FHD", "price": "32700", "catalog_id": "3", "created_at": new Date(), "updated_at": new Date()},
... {"name": "Lenovo SFF 7xb7", "description": "Desctop HDD", "price": "35700", "catalog_id": "4", "created_at": new Date(), "updated_at": new Date()}])
{
	"acknowledged" : true,
	"insertedIds" : [
		ObjectId("604e109c98bef055dfaaf1dc"),
		ObjectId("604e109c98bef055dfaaf1dd"),
		ObjectId("604e109c98bef055dfaaf1de"),
		ObjectId("604e109c98bef055dfaaf1df")
	]
}
> db.products.find().pretty()
{
	"_id" : ObjectId("604e109c98bef055dfaaf1dc"),
	"name" : "Intel Core i5 7400",
	"description" : "Desctop processor",
	"price" : "12700",
	"catalog_id" : "1",
	"created_at" : ISODate("2021-03-14T13:33:16.374Z"),
	"updated_at" : ISODate("2021-03-14T13:33:16.374Z")
}
{
	"_id" : ObjectId("604e109c98bef055dfaaf1dd"),
	"name" : "Asus ROG Maximus",
	"description" : "Laptop motherboard",
	"price" : "19310",
	"catalog_id" : "2",
	"created_at" : ISODate("2021-03-14T13:33:16.374Z"),
	"updated_at" : ISODate("2021-03-14T13:33:16.374Z")
}
{
	"_id" : ObjectId("604e109c98bef055dfaaf1de"),
	"name" : "Samsung C24R",
	"description" : "Monitor FHD",
	"price" : "32700",
	"catalog_id" : "3",
	"created_at" : ISODate("2021-03-14T13:33:16.374Z"),
	"updated_at" : ISODate("2021-03-14T13:33:16.374Z")
}
{
	"_id" : ObjectId("604e109c98bef055dfaaf1df"),
	"name" : "Lenovo SFF 7xb7",
	"description" : "Desctop HDD",
	"price" : "35700",
	"catalog_id" : "4",
	"created_at" : ISODate("2021-03-14T13:33:16.374Z"),
	"updated_at" : ISODate("2021-03-14T13:33:16.374Z")
}
> db.products.find({name: "Samsung C24R"}).pretty()
{
	"_id" : ObjectId("604e109c98bef055dfaaf1de"),
	"name" : "Samsung C24R",
	"description" : "Monitor FHD",
	"price" : "32700",
	"catalog_id" : "3",
	"created_at" : ISODate("2021-03-14T13:33:16.374Z"),
	"updated_at" : ISODate("2021-03-14T13:33:16.374Z")
}
> 















