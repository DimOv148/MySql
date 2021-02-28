-- 1. Создать и заполнить таблицы лайков и постов.

-- таблица likes
SELECT * FROM likes LIMIT 5;

id	user_id	target_id	target_type_id	created_at
1	85	8	4	2021-02-25 18:34:55
2	109	183	4	2021-02-25 18:34:55
3	182	153	1	2021-02-25 18:34:55
4	23	68	2	2021-02-25 18:34:55
5	131	54	2	2021-02-25 18:34:55

-- таблица posts, колонки head и body не включались в выборку для удобного просмотра
SELECT id, user_id, media_id , is_public ,is_archived , created_at , updated_at FROM posts LIMIT 5;

id	user_id	media_id	is_public	is_archived	created_at	updated_at
1	63	198	0	0	2021-02-02 00:02:12	2016-02-25 01:16:56
2	107	156	1	1	2014-10-05 08:17:03	2019-03-28 10:18:32
3	141	110	1	1	2017-04-17 12:19:28	2018-05-17 05:43:33
4	200	115	0	0	2016-10-18 04:53:08	2015-11-18 05:52:07
5	150	125	0	1	2015-10-27 21:11:34	2011-03-18 22:18:56

 -- 2. Создать все необходимые внешние ключи и диаграмму отношений.
-- Скриншот прилагается

-- 3. Определить кто больше поставил лайков (всего) - мужчины или женщины?
(
SELECT
	'Male' AS gender, count(*) AS number_likes
FROM
	likes
WHERE
	user_id IN (SELECT user_id FROM profiles WHERE gender = 'm')
)
UNION 
(
SELECT
'Female' AS gender, count(*) AS number_likes
FROM
likes
WHERE
	user_id IN (SELECT user_id FROM profiles WHERE gender = 'f')
)
ORDER BY number_likes DESC LIMIT 1;

-- 4. Подсчитать количество лайков которые получили 10 самых молодых пользователей.

SELECT
	count(*) AS numbers_likes
FROM
	likes
WHERE
	target_type_id = (SELECT id FROM target_types WHERE name = 'users')
	AND 
	target_id IN (SELECT *	FROM (SELECT user_id FROM profiles ORDER BY birthday DESC LIMIT 10) AS user_id);


-- 5. Найти 10 пользователей, которые проявляют наименьшую активность в
-- использовании социальной сети
-- (критерии активности необходимо определить самостоятельно).

SELECT id, COUNT(*) AS count FROM (
(SELECT id FROM users WHERE id NOT IN (SELECT from_user_id FROM messages GROUP BY from_user_id))
UNION ALL 
(SELECT id FROM users WHERE id NOT IN (SELECT user_id FROM posts GROUP BY user_id)) 	
UNION ALL 	
(SELECT id FROM users WHERE id NOT IN (SELECT user_id FROM media GROUP BY user_id)) 	
UNION ALL 	
(SELECT id FROM users WHERE id NOT IN (SELECT user_id FROM likes GROUP BY user_id))) AS id GROUP BY id ORDER BY count DESC LIMIT 10; 




