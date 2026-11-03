--1. Колики удео у укупном броју голова лиге у сезони 2024/25 има сваки клуб? Ко има највећи удео?
WITH team_goals AS (

    SELECT
        home_team_id AS team_id,
        SUM(home_goals) AS goals
    FROM matches
    WHERE season = '2024/25'
    GROUP BY home_team_id

    UNION ALL

    SELECT
        away_team_id AS team_id,
        SUM(away_goals) AS goals
    FROM matches
    WHERE season = '2024/25'
    GROUP BY away_team_id),
club_goals AS (
    SELECT
        team_id,
        SUM(goals) AS total_goals
    FROM team_goals
    GROUP BY team_id)
SELECT
    t.team_name,
    cg.total_goals,
    ROUND(
        100.0 * cg.total_goals /
        SUM(cg.total_goals) OVER (),
        2
    ) AS goal_share_pct
FROM club_goals cg
JOIN teams t
    ON cg.team_id = t.team_id
ORDER BY goal_share_pct DESC;

--najveci udeo ima tim Kingsbridge City

--2. Која су три стадиона са највећом просечном посетом у сезони 2024/25

WITH stadium_avg AS (
    SELECT
        s.stadium_name,
        ROUND(AVG(m.attendance), 2) AS avg_attendance,
        RANK() OVER (
            ORDER BY AVG(m.attendance) DESC
        ) AS stadium_rank
    FROM matches m
    JOIN stadiums s
        ON m.stadium_id = s.stadium_id
    WHERE m.season = '2024/25'
      AND m.attendance IS NOT NULL
    GROUP BY s.stadium_name)
SELECT *
FROM stadium_avg
WHERE stadium_rank <= 3
ORDER BY stadium_rank;
--Harbourside Park, Kingsbridge Stadium i Northport Arena

--3.За сваки клуб, ко је дао последњи гол клуба у сезони 2024/25 и када? Који клуб је последњи гол дао најраније?
WITH goals AS (

    SELECT
        t.team_name,
        p.first_name,
        p.last_name,
        m.kickoff_ts,
        me.minute,
        ROW_NUMBER() OVER (
            PARTITION BY me.team_id
            ORDER BY
                m.kickoff_ts DESC,
                me.minute DESC
        ) AS rn
    FROM match_events me
    JOIN matches m
        ON me.match_id = m.match_id
    JOIN teams t
        ON me.team_id = t.team_id
    JOIN players p
        ON me.player_id = p.player_id
    WHERE m.season = '2024/25'
      AND me.event_type = 'goal')

SELECT
    team_name,
    first_name,
    last_name,
    kickoff_ts
FROM goals
WHERE rn = 1
ORDER BY kickoff_ts;

--4.За домаће утакмице клуба Northport United у сезони 2024/25 прикажите посету и промену у односу на претходну домаћу утакмицу. Где је највећи пад?
SELECT
    kickoff_ts,
    attendance,
    attendance
    - LAG(attendance) OVER (
        ORDER BY kickoff_ts
      ) AS attendance_change
FROM matches
WHERE season = '2024/25'
  AND home_team_id = 1
ORDER BY kickoff_ts;

--5.Пратите бодове клуба Northport City утакмицу по утакмицу у сезони 2024/25. У којој утакмици по реду и ког датума је прешао 50 бодова?
WITH points AS (

    SELECT
        kickoff_ts,

        CASE
            WHEN home_team_id = 2 AND home_goals > away_goals THEN 3
            WHEN away_team_id = 2 AND away_goals > home_goals THEN 3
            WHEN home_goals = away_goals THEN 1
            ELSE 0
        END AS pts

    FROM matches
    WHERE season = '2024/25'
      AND (home_team_id = 2 OR away_team_id = 2)
)
SELECT kickoff_ts, cumulative_points
FROM (

    SELECT
        kickoff_ts,
        SUM(pts) OVER (ORDER BY kickoff_ts) AS cumulative_points
    FROM points
) t
WHERE cumulative_points >= 50
ORDER BY kickoff_ts
LIMIT 1;