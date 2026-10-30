--1. Колики удео у укупном броју голова лиге у сезони 2024/25 има сваки клуб? Ко има највећи удео?

SELECT
    t.team_name,
    SUM(pms.shots) AS golovi,
    ROUND(
        100.0 * SUM(pms.shots) /
        SUM(SUM(pms.shots)) OVER (),
        2
    ) AS udeo_proc
FROM player_match_stats pms
JOIN matches m
    ON pms.match_id = m.match_id
JOIN teams t
    ON pms.team_id = t.team_id
WHERE m.season = '2024/25'
GROUP BY t.team_name
ORDER BY udeo_proc DESC;

--2. Која су три стадиона са највећом просечном посетом у сезони 2024/25

SELECT *
FROM (
    SELECT
        s.stadium_name,
        ROUND(AVG(m.attendance), 0) AS prosecna_poseta,
        RANK() OVER (
            ORDER BY AVG(m.attendance) DESC
        ) AS rang
    FROM matches m
    JOIN stadiums s
        ON m.stadium_id = s.stadium_id
    WHERE m.season = '2024/25'
    GROUP BY s.stadium_name
) x
WHERE rang <= 3;
