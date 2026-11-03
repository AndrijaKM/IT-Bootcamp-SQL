-- dim_team

CREATE OR REPLACE TABLE dim_team AS
SELECT *
FROM teams;


-- dim_player

CREATE OR REPLACE TABLE dim_player AS
SELECT *
FROM players;

INSERT INTO dim_player
VALUES (
    -1,
    'Unknown',
    'Player',
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL
);


-- dim_referee

CREATE OR REPLACE TABLE dim_referee AS
SELECT *
FROM referees;


-- dim_date

CREATE OR REPLACE TABLE dim_date AS
SELECT DISTINCT
    CAST(date_format(kickoff_ts, 'yyyyMMdd') AS INT) AS date_key,
    DATE(kickoff_ts) AS full_date,
    YEAR(kickoff_ts) AS year,
    MONTH(kickoff_ts) AS month,
    DAY(kickoff_ts) AS day
FROM matches;


-- fact_card

CREATE OR REPLACE TABLE fact_card AS
SELECT
    me.event_id,
    me.match_id,
    CAST(date_format(m.kickoff_ts, 'yyyyMMdd') AS INT) AS date_key,
    me.team_id,
    CASE
        WHEN p.player_id IS NULL THEN -1
        ELSE me.player_id
    END AS player_id,
    m.referee_id,
    me.event_type AS card_type
FROM match_events me
JOIN matches m
    ON me.match_id = m.match_id
LEFT JOIN players p
    ON me.player_id = p.player_id
WHERE me.event_type IN (
    'yellow_card',
    'second_yellow',
    'red_card'
);

-- VALIDATION


-- Number of card events in source

SELECT COUNT(*) AS source_card_events
FROM match_events
WHERE event_type IN (
    'yellow_card',
    'second_yellow',
    'red_card'
);


-- broj redova

SELECT COUNT(*) AS fact_card_rows
FROM fact_card;

--broj redova jednak broju kartonskih dogadjaja

SELECT
    (SELECT COUNT(*)
     FROM match_events
     WHERE event_type IN (
        'yellow_card',
        'second_yellow',
        'red_card'
     )) AS source_count,

    (SELECT COUNT(*)
     FROM fact_card) AS fact_count;


-- koliko kartona ima player -1

SELECT COUNT(*) AS unknown_player_cards
FROM fact_card
WHERE player_id = -1;