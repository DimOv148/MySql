
-- 1. ����� � ������� users ���� created_at � updated_at ��������� ��������������. ��������� �� �������� ����� � ��������.
INSERT INTO user1 (created_at, updated_at) VALUES (NOW(), NOW());
-- 2. ������� users ���� �������� ��������������. ������ created_at � updated_at ���� ������ ����� VARCHAR
-- � � ��� ������ ����� ���������� �������� � ������� 20.10.2017 8:10. ���������� ������������� ���� � 
-- ���� DATETIME, �������� �������� ����� ��������.
UPDATE user1 SET created_at = STR_TO_DATE(created_at, '%d.%m.%Y %H:%i'), updated_at = STR_TO_DATE(updated_at, '%d.%m.%Y %H:%i');
ALTER TABLE user1 MODIFY created_at DATETIME, MODIFY updated_at DATETIME;
-- 3. � ������� ��������� ������� storehouses_products � ���� value ����� ����������� ����� ������ �����: 0,
-- ���� ����� ���������� � ���� ����, ���� �� ������ ������� ������. ���������� ������������� ������ ����� �������, 
-- ����� ��� ���������� � ������� ���������� �������� value. ������ ������� ������ ������ ���������� � �����, ����� ���� �������.
SELECT * FROM storehouses_products1 ORDER BY CASE WHEN value = 0 THEN ~ 0 ELSE value END, value;
-- 4. (�� �������) �� ������� users ���������� ������� �������������, ���������� � ������� � ���. 
-- ������ ������ � ���� ������ ���������� �������� (may, august)
SELECT * FROM users WHERE DATE_FORMAT(birthday_at, '%M') IN ('may','august');
-- 5. (�� �������) �� ������� catalogs ����������� ������ ��� ������ �������. 
-- SELECT * FROM catalogs WHERE id IN (5, 1, 2); ������������ ������ � �������, �������� � ������ IN.
SELECT * FROM catalogs WHERE id IN (5, 1, 2) ORDER BY FIELD(id, 5,1,2);
-- ����������� ������� ������� ������������� � ������� users.
SELECT ROUND(AVG(timestampdiff(YEAR, birthday_at, NOW())), 2) AS Average_age FROM users;
-- ����������� ���������� ���� ��������, ������� ���������� �� ������ �� ���� ������. 
-- ������� ������, ��� ���������� ��� ������ �������� ����, � �� ���� ��������.
SELECT count(*) AS number_days, DAYNAME(CONCAT(YEAR (NOW()), '-', MONTH(birthday_at),'-', DAYOFMONTH(birthday_at))) AS daynam FROM users group BY daynam ;
-- (�� �������) ����������� ������������ ����� � ������� �������.
SELECT EXP (SUM(LOG(value))) FROM vales;







