
-- 1. Пусть в таблице users поля created_at и updated_at оказались незаполненными. Заполните их текущими датой и временем.
INSERT INTO user1 (created_at, updated_at) VALUES (NOW(), NOW());
-- 2. Таблица users была неудачно спроектирована. Записи created_at и updated_at были заданы типом VARCHAR
-- и в них долгое время помещались значения в формате 20.10.2017 8:10. Необходимо преобразовать поля к 
-- типу DATETIME, сохранив введённые ранее значения.
UPDATE user1 SET created_at = STR_TO_DATE(created_at, '%d.%m.%Y %H:%i'), updated_at = STR_TO_DATE(updated_at, '%d.%m.%Y %H:%i');
ALTER TABLE user1 MODIFY created_at DATETIME, MODIFY updated_at DATETIME;
-- 3. В таблице складских запасов storehouses_products в поле value могут встречаться самые разные цифры: 0,
-- если товар закончился и выше нуля, если на складе имеются запасы. Необходимо отсортировать записи таким образом, 
-- чтобы они выводились в порядке увеличения значения value. Однако нулевые запасы должны выводиться в конце, после всех записей.
SELECT * FROM storehouses_products1 ORDER BY CASE WHEN value = 0 THEN ~ 0 ELSE value END, value;
-- 4. (по желанию) Из таблицы users необходимо извлечь пользователей, родившихся в августе и мае. 
-- Месяцы заданы в виде списка английских названий (may, august)
SELECT * FROM users WHERE DATE_FORMAT(birthday_at, '%M') IN ('may','august');
-- 5. (по желанию) Из таблицы catalogs извлекаются записи при помощи запроса. 
-- SELECT * FROM catalogs WHERE id IN (5, 1, 2); Отсортируйте записи в порядке, заданном в списке IN.
SELECT * FROM catalogs WHERE id IN (5, 1, 2) ORDER BY FIELD(id, 5,1,2);
-- Подсчитайте средний возраст пользователей в таблице users.
SELECT ROUND(AVG(timestampdiff(YEAR, birthday_at, NOW())), 2) AS Average_age FROM users;
-- Подсчитайте количество дней рождения, которые приходятся на каждый из дней недели. 
-- Следует учесть, что необходимы дни недели текущего года, а не года рождения.
SELECT count(*) AS number_days, DAYNAME(CONCAT(YEAR (NOW()), '-', MONTH(birthday_at),'-', DAYOFMONTH(birthday_at))) AS daynam FROM users group BY daynam ;
-- (по желанию) Подсчитайте произведение чисел в столбце таблицы.
SELECT EXP (SUM(LOG(value))) FROM vales;







