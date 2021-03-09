-- ������������ ������� �� ���� �����������, ����������, ��������������

-- 1. � ���� ������ shop � sample ������������ ���� � �� �� �������, ������� ���� ������. 
-- ����������� ������ id = 1 �� ������� shop.users � ������� sample.users. ����������� ����������.

START TRANSACTION;
INSERT INTO shop.users (SELECT * FROM shop7.users WHERE id=1);
COMMIT;

-- 2. �������� �������������, ������� ������� �������� name �������� ������� �� ������� products 
-- � ��������������� �������� �������� name �� ������� catalogs.
CREATE OR REPLACE VIEW prod AS
SELECT products.name AS prod_name, catalogs.name AS cat_name
FROM products LEFT JOIN catalogs
ON products.catalog_id = catalogs.id;

SELECT * FROM prod;

-- 3.�� �������) ����� ������� ������� � ����������� ����� created_at. 
-- � ��� ��������� ���������� ����������� ������ �� ������ 2018 ���� '2018-08-01', 
-- '2018-08-04', '2018-08-16' � 2018-08-17. ��������� ������, ������� ������� ������ ������ ��� �� ������, 
-- ��������� � �������� ���� �������� 1, ���� ���� ������������ � �������� ������� � 0, ���� ��� �����������.
 
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

-- 4. (�� �������) ����� ������� ����� ������� � ����������� ����� created_at. 
-- �������� ������, ������� ������� ���������� ������ �� �������, �������� ������ 5 ����� ������ �������.


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


-- ������������ ������� �� ���� ������������������ MySQL�

-- 1.�������� ���� ������������� ������� ����� ������ � ���� ������ shop. 
-- ������� ������������ shop_read ������ ���� �������� ������ ������� �� ������ ������, 
-- ������� ������������ shop � ����� �������� � �������� ���� ������ shop.

CREATE USER 'shop_read'@'localhost' IDENTIFIED WITH sha256_password BY 'qwerty';
GRANT SELECT ON shop.* TO 'shop_reader'@'localhost';

CREATE USER 'shop'@'localhost' IDENTIFIED WITH sha256_password BY 'qwerty';
GRANT ALL ON shop.* TO 'shop'@'localhost';
GRANT GRANT OPTION ON shop.* TO 'shop'@'localhost';


-- ������������ ������� �� ���� ��������� ��������� � �������, ��������"

-- 1.�������� �������� ������� hello(), ������� ����� ���������� �����������, 
-- � ����������� �� �������� ������� �����. � 6:00 �� 12:00 ������� ������ ����������
--  ����� "������ ����", � 12:00 �� 18:00 ������� ������ ���������� ����� "������ ����", 
-- � 18:00 �� 00:00 � "������ �����", � 00:00 �� 6:00 � "������ ����".

-- � DBeaver DELIMITER �� �����������, ������� ������� ������ ��� ����� ������� Ubuntu ��� 
-- ���� �������� ��������� � DBeaver. �� ������� �� ����������.

DELIMITER //
DROP FUNCTION IF EXISTS hello //
CREATE FUNCTION hello ()
RETURNS VARCHAR(255) DETERMINISTIC 
BEGIN
	RETURN CASE
	WHEN CURTIME() BETWEEN "06:00" AND "12:00" THEN "������ ����"
	WHEN CURTIME() BETWEEN "12:01" AND "18:00" THEN "������ ����"
	WHEN CURTIME() BETWEEN "18:01" AND "24:00" THEN "������ �����"
	ELSE "������ ����"
    END;
END //

SHOW CREATE FUNCTION hello() //
DELIMITER ;


-- 2. � ������� products ���� ��� ��������� ����: name � ��������� ������ � description � ��� ���������. 
-- ��������� ����������� ����� ����� ��� ���� �� ���. ��������, ����� ��� ���� ��������� �������������� �������� NULL �����������.
-- ��������� ��������, ��������� ����, ����� ���� �� ���� ����� ��� ��� ���� ���� ���������. ��� ������� ��������� �����
-- NULL-�������� ���������� �������� ��������.

-- ���� � ���������� DBeaver: ����-���������-����������-�������� SQL- ����������� SQL � ������� "�����������" � ����
-- "����������� ����������" ���������� // ������ ; �� �������� ��� ����������� � // � ; ���� delimiter �� �������� �� �����������.  

DELIMITER //

CREATE TRIGGER products_insert BEFORE INSERT ON products FOR EACH ROW
BEGIN
  IF NEW.name IS NULL AND NEW.desription IS NULL
    THEN SIGNAL sqlstate '45001' SET message_text = "�������� �������� � ��� �������� �e ����� ���� NULL"; 
  end if;
END;
//

CREATE TRIGGER products_update BEFORE UPDATE ON products FOR EACH ROW
BEGIN
  IF NEW.name IS NULL AND NEW.desription IS NULL
    THEN SIGNAL sqlstate '45001' SET message_text = "�������� �������� � ��� �������� �e ����� ���� NULL"; 
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
