-- Практическое задание по теме “Транзакции, переменные, представления”

-- 1. В базе данных shop и sample присутствуют одни и те же таблицы, учебной базы данных. 
-- Переместите запись id = 1 из таблицы shop.users в таблицу sample.users. Используйте транзакции.

START TRANSACTION;
INSERT INTO shop.users (SELECT * FROM shop7.users WHERE id=1);
COMMIT;

-- 2. Создайте представление, которое выводит название name товарной позиции из таблицы products 
-- и соответствующее название каталога name из таблицы catalogs.
CREATE OR REPLACE VIEW prod AS
SELECT products.name AS prod_name, catalogs.name AS cat_name
FROM products LEFT JOIN catalogs
ON products.catalog_id = catalogs.id;

SELECT * FROM prod;

-- 3.по желанию) Пусть имеется таблица с календарным полем created_at. 
-- В ней размещены разряженые календарные записи за август 2018 года '2018-08-01', 
-- '2018-08-04', '2018-08-16' и 2018-08-17. Составьте запрос, который выводит полный список дат за август, 
-- выставляя в соседнем поле значение 1, если дата присутствует в исходном таблице и 0, если она отсутствует.
 
CREATE TABLE dates_all_august (
  id SERIAL PRIMARY KEY, 
  all_august DATE 
);  

DROP PROCEDURE IF EXISTS filldates;
-- DELIMITER //
CREATE PROCEDURE filldates (date_Start DATE, date_End DATE)
BEGIN
	WHILE date_Start <= date_End DO
	INSERT INTO dates_all_august (all_august) VALUES (date_Start);
	SET date_Start = DATE_ADD(date_Start, INTERVAL 1 DAY);
	END WHILE;
END;
//
-- DELIMITER ;
CALL filldates ('2018-08-01', '2018-08-31');

CREATE TABLE dates_august (
  id SERIAL PRIMARY KEY, 
  august DATE 
);

INSERT INTO dates_august (august) VALUES ('2018-08-01'), ('2018-08-04'), ('2018-08-16'), ('2018-08-17');

SELECT dates_all_august.all_august, 
IF (dates_all_august.all_august = dates_august.august, '1', '0') AS numbers
FROM dates_all_august, dates_august;

-- 4. (по желанию) Пусть имеется любая таблица с календарным полем created_at. 
-- Создайте запрос, который удаляет устаревшие записи из таблицы, оставляя только 5 самых свежих записей.


DROP TABLE IF EXISTS dates; 
CREATE TABLE dates (
  id SERIAL PRIMARY KEY, 
  dt DATE 
);  

SELECT * FROM dates ;

DROP PROCEDURE IF EXISTS filldate;
-- DELIMITER //
CREATE PROCEDURE filldate (date_Start DATE, date_End DATE)
BEGIN
	WHILE date_Start <= date_End DO
	INSERT INTO dates (dt) VALUES (date_Start);
	SET date_Start = DATE_ADD(date_Start, INTERVAL 1 DAY);
	END WHILE;
END;
//
-- DELIMITER ;

CALL filldate ('2021-02-01', '2021-02-28');

PREPARE del_date FROM 'DELETE FROM dates ORDER BY dt DESC LIMIT ?';
SET @cnt = (SELECT count(dt)-5 FROM dates);
EXECUTE del_date USING @cnt;


SELECT * FROM dates ;


SELECT count(*)-5 FROM dates;
SELECT dt FROM dates ORDER BY dt DESC LIMIT 23;
SELECT version();


-- Практическое задание по теме “Администрирование MySQL”

-- 1.Создайте двух пользователей которые имеют доступ к базе данных shop. 
-- Первому пользователю shop_read должны быть доступны только запросы на чтение данных, 
-- второму пользователю shop — любые операции в пределах базы данных shop.

CREATE USER 'shop_read'@'localhost' IDENTIFIED WITH sha256_password BY 'qwerty';
GRANT SELECT ON shop.* TO 'shop_reader'@'localhost';

CREATE USER 'shop'@'localhost' IDENTIFIED WITH sha256_password BY 'qwerty';
GRANT ALL ON shop.* TO 'shop'@'localhost';
GRANT GRANT OPTION ON shop.* TO 'shop'@'localhost';


-- Практическое задание по теме “Хранимые процедуры и функции, триггеры"

-- 1.Создайте хранимую функцию hello(), которая будет возвращать приветствие, 
-- в зависимости от текущего времени суток. С 6:00 до 12:00 функция должна возвращать
--  фразу "Доброе утро", с 12:00 до 18:00 функция должна возвращать фразу "Добрый день", 
-- с 18:00 до 00:00 — "Добрый вечер", с 00:00 до 6:00 — "Доброй ночи".

-- в DBeaver DELIMITER не срабатывает, функция работет только или через консоль Ubuntu или 
-- если изменить настройки в DBeaver. По другому не получилось.

DELIMITER //
DROP FUNCTION IF EXISTS hello //
CREATE FUNCTION hello ()
RETURNS VARCHAR(255) DETERMINISTIC 
BEGIN
	RETURN CASE
	WHEN CURTIME() BETWEEN "06:00" AND "12:00" THEN "Доброе утро"
	WHEN CURTIME() BETWEEN "12:01" AND "18:00" THEN "Добрый день"
	WHEN CURTIME() BETWEEN "18:01" AND "24:00" THEN "Добрый вечер"
	ELSE "Доброй ночи"
    END;
END //

SHOW CREATE FUNCTION hello() //
DELIMITER ;


-- 2. В таблице products есть два текстовых поля: name с названием товара и description с его описанием. 
-- Допустимо присутствие обоих полей или одно из них. Ситуация, когда оба поля принимают неопределенное значение NULL неприемлема.
-- Используя триггеры, добейтесь того, чтобы одно из этих полей или оба поля были заполнены. При попытке присвоить полям
-- NULL-значение необходимо отменить операцию.

-- Если в настройках DBeaver: Окна-Настройки-Рендакторы-Редактор SQL- Выполонение SQL в разделе "Разделители" в поле
-- "Разделитель операторов" установить // вместо ; то работают оба разделителя и // и ; хотя delimiter по прежнему не выполняется.  

DELIMITER //

CREATE TRIGGER products_insert BEFORE INSERT ON products FOR EACH ROW
BEGIN
  IF NEW.name IS NULL AND NEW.desription IS NULL
    THEN SIGNAL sqlstate '45001' SET message_text = "Название продукта и его описание нe может быть NULL"; 
  end if;
END;
//

CREATE TRIGGER products_update BEFORE UPDATE ON products FOR EACH ROW
BEGIN
  IF NEW.name IS NULL AND NEW.desription IS NULL
    THEN SIGNAL sqlstate '45001' SET message_text = "Название продукта и его описание нe может быть NULL"; 
  end if;
END;
//
DELIMITER ;

SHOW triggers;
DROP TRIGGER IF EXISTS products_insert;
DROP TRIGGER IF EXISTS e_insert;

INSERT INTO products (name, desription) VALUES (NULL, 'bla bla bla');  
INSERT INTO products (name, desription) VALUES (NULL, NULL);
SELECT * FROM products;

UPDATE products 
SET name = NULL, desription = NULL WHERE id = 1;
UPDATE products 
SET name = NULL, desription = 'jnsdjsdnvlfdl fdnjnffgsfdksngnfd ldfngjfsdjsnjsngh' WHERE id = 1;
SELECT * FROM products;
