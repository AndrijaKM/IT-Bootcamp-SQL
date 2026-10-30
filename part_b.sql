--1. Преглед сезоне: број утакмица и голова, просечан број голова по утакмици, удео победа домаћина, нерешених и победа гостију.
SELECT
season,
COUNT() AS broj_utakmica,
SUM(home_goals + away_goals) AS broj_golova
FROM matches
WHERE season = '2024/25'
GROUP BY season;
--broj utakmica: 380; broj golova: 1092, prosecan broj golova: 2.87; udeo pobeda domacina: 41.32
-- udeo neresenih: 25; udeo pobeda gostiju: 33.68
SELECT
season,
ROUND(AVG(home_goals + away_goals), 2) AS prosecno_golova
FROM matches
WHERE season = '2024/25'
group by season;
SELECT
ROUND(100 * COUNT(CASE WHEN home_goals > away_goals THEN 1 END)/ COUNT(),2) AS procenat_pobeda_domacina
FROM matches
WHERE season = '2024/25';
SELECT
ROUND(100 * COUNT(CASE WHEN home_goals = away_goals THEN 1 END)/ COUNT(),2) AS procenat_neresenih
FROM matches
WHERE season = '2024/25';
SELECT
ROUND(100 * COUNT(CASE WHEN home_goals < away_goals THEN 1 END)/ COUNT(),2) AS procenat_pobeda_gostiju
FROM matches
WHERE season = '2024/25';
SELECT
MONTH(kickoff_ts) AS mesec,
COUNT() AS broj_utakmica,
SUM(home_goals + away_goals) AS broj_golova,
ROUND(AVG(home_goals + away_goals), 2) AS prosecno_golova
FROM matches
WHERE season = '2024/25'
GROUP BY MONTH(kickoff_ts)
ORDER BY mesec;
--mesec sa najviše golova: decembar (145)
--mesec sa najviše utakmica: decembar (52)
--mesec sa najvećim prosekom golova: jun (3.54)
--Публика: просечна посета и попуњеност по стадиону; утакмице без податка о посети и утакмица без публике.
SELECT
stadium_id,
ROUND(AVG(attendance), 0) AS prosecna_poseta
FROM matches
WHERE season = '2024/25'
GROUP BY stadium_id;
--prosecna poseta po stadionu
SELECT match_id
FROM matches
WHERE season = '2024/25' AND attendance IS NULL;
-- na 9 utakmica nemamo podatke o poseti
SELECT count()
FROM matches
WHERE season = '2024/25' AND attendance = 0;
--Судије: за сваког судију број утакмица и картони по утакмици
SELECT
referee_id,
COUNT() AS broj_utakmica
FROM matches
WHERE season = '2024/25'
GROUP BY referee_id
ORDER BY referee_id;
--svaki sudija je sudio na 20 utakmica
SELECT
m.referee_id,
COUNT() AS broj_kartona
FROM matches m
JOIN match_events me
ON m.match_id = me.match_id
WHERE m.season = '2024/25'
AND me.event_type IN ('yellow_card', 'red_card')
GROUP BY m.referee_id
ORDER BY m.referee_id;
--Играчи: пет најбољих стрелаца и пет најбољих асистената.
SELECT
player_id,
COUNT() AS broj_golova
FROM match_events me
JOIN matches m
ON me.match_id = m.match_id
WHERE m.season = '2024/25'
AND me.event_type = 'goal'
GROUP BY player_id
ORDER BY broj_golova DESC
LIMIT 6;

-- SELECT first_name, last_name
-- FROM players
-- WHERE player_id=167;
SELECT
related_player_id,
COUNT() AS broj_asistencija
FROM match_events me
JOIN matches m
ON me.match_id = m.match_id
WHERE m.season = '2024/25'
AND related_player_id IS NOT NULL
GROUP BY related_player_id
ORDER BY broj_asistencija DESC
LIMIT 5;