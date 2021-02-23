CREATE STREAM USER_GAME (USER VARCHAR, GAME STRUCT<SCORE INT, LIVES INT, LEVEL INT>) WITH (KAFKA_TOPIC='USER_GAME', VALUE_FORMAT='JSON');
CREATE STREAM USER_LOSSES (USER VARCHAR) WITH (KAFKA_TOPIC='USER_LOSSES', VALUE_FORMAT='JSON');
CREATE TABLE LOSSES_PER_USER AS SELECT USER AS USER, COUNT(USER) AS TOTAL_LOSSES FROM USER_LOSSES GROUP BY USER;
CREATE TABLE STATS_PER_USER AS SELECT UG.USER AS USER, MAX(UG.GAME->SCORE) AS HIGHEST_SCORE, MAX(UG.GAME->LEVEL) AS HIGHEST_LEVEL, MAX(CASE WHEN LPU.TOTAL_LOSSES IS NULL THEN CAST(0 AS BIGINT) ELSE LPU.TOTAL_LOSSES END) AS TOTAL_LOSSES FROM USER_GAME UG LEFT JOIN LOSSES_PER_USER LPU ON UG.USER = LPU.USER GROUP BY UG.USER;
CREATE TABLE SUMMARY_STATS AS SELECT 'SUMMARY_KEY' AS SUMMARY_KEY, MAX(GAME->SCORE) AS HIGHEST_SCORE_VALUE, COLLECT_SET(USER) AS USERS_SET_VALUE  FROM USER_GAME GROUP BY 'SUMMARY_KEY';
