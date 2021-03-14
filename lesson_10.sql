-- Урок 10. Вебинар. Транзакции, переменные, представления. Администрирование. Хранимые процедуры и функции, триггеры

-- 1. Проанализировать какие запросы могут выполняться наиболее часто в процессе работы приложения и добавить необходимые индексы.
-- Для поиска медиа контента по имени испольнителя можно добавить индекс для пооля metadata таблицы media. 

ALTER TABLE media ADD COLUMN name_virtual VARCHAR (64) GENERATED ALWAYS AS (metadata ->> '$.owner') NOT NULL AFTER metadata; 
CREATE INDEX media_name_virtual_idx ON media (name_virtual);
SHOW INDEX FROM media;

-- для более быстрого поиска постов можного боавит индекс на поле head таблицы posts.

CREATE INDEX posts_head_idx ON posts (head);
SHOW INDEX FROM posts;

-- 2. Задание на оконные функции
-- Построить запрос, который будет выводить следующие столбцы: имя группы
-- среднее количество пользователей в группах
-- самый молодой пользователь в группе
-- самый старший пользователь в группе
-- общее количество пользователей в группе
-- всего пользователей в системе
-- отношение в процентах (общее количество пользователей в группе / всего пользователей в системе) * 100

SELECT DISTINCT community_id, name, 
ROUND(((SELECT COUNT(*) FROM (SELECT count(*) FROM communities_users GROUP BY user_id ) AS cnt_user) / 
(SELECT COUNT(*) FROM communities))) AS aver_user_to_communities,   
LAST_VALUE(user_id ) OVER w AS younger_user,
FIRST_VALUE(user_id ) OVER w AS olderer_user,
COUNT(user_id ) OVER w AS users_in_group,
(SELECT  COUNT(id) FROM users) AS total_users,
COUNT(user_id ) OVER (PARTITION BY community_id ORDER BY birthday ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
/ (SELECT COUNT(id) AS total_users FROM users) * 100 AS '%%'
FROM (SELECT communities.name, communities_users.community_id, communities_users.user_id, profiles.birthday 
FROM communities_users JOIN profiles ON communities_users.user_id = profiles.user_id JOIN communities ON communities_users.community_id = communities.id) AS tab
WINDOW w AS (PARTITION BY community_id ORDER BY birthday ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING);
