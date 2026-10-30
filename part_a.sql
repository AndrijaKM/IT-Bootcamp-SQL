--1. Колико утакмица је одиграно у фебруару 2025? --rezultat 40
select
count (distinct match_id) as num_of_matches
from matches
where month(kickoff_ts)=2 and year(kickoff_ts)=2025;
--2. Који стадион има највећи капацитет, а који је највећи стадион неког клуба?
-- stadion sa najvecim kapacitetom je National Stadium, capacity: 80k
select stadium_name, capacity
from stadiums
order by capacity desc
limit 1;
--klub Northport United poseduje stadion Harbourside Park kapaciteta 52k gledalaca
select s.stadium_name, s.capacity, t.team_name
from stadiums s
join teams t on s.stadium_id=t.stadium_id
order by s.capacity desc
limit 1;
--3. Колико играча у лиги има српско држављанство (nationality = 'Serbia')? --42 srpskih igraca
select count() as serbian_players
from players
where nationality = 'Serbia';
--4. Колико утакмица је завршено резултатом 1:1? --94
select count() as number_of_games
from matches
where home_goals=1 and away_goals=1;
--5. Колика је просечна посета по сезони?
select season, avg(attendance) as prosecna_poseta
from matches
group by season;
--6. Колико голова је дато из пенала по сезони? --2023/24:104; 2024/25:109
select m.season, count() as golovi_iz_penala
from matches m
join match_events me on m.match_id=me.match_id
where event_type='penalty_goal'
group by m.season;
--7. Колико различитих играча је дало бар један гол у сезони 2024/25? --299
select count(distinct player_id) as br_razlicitih_stralaca
from match_events me
join matches m on m.match_id=me.match_id
where m.season='2024/25' and me.event_type='goal';
--8. Који судија је највише пута судио утакмице клуба Northport United? --Peter Lindgren
select r.referee_name, count() as br_utakmica
from matches m
join referees r on m.referee_id=r.referee_id
where m.home_team_id = (
SELECT team_id
FROM teams
WHERE team_name = 'Northport United')
or m.away_team_id = (
SELECT team_id
FROM teams
WHERE team_name = 'Northport United')
group by r.referee_name
order by br_utakmica desc;
--9.Који судија је у сезони 2024/25 имао највећи удео утакмица у којима је досуђен бар један пенал, дат или промашен?
select m.referee_id,
COUNT(DISTINCT m.match_id) AS utakmice_sa_penalom
from matches m
join match_events me
ON m.match_id = me.match_id
where m.season = '2024/25'
and me.event_type LIKE '%Penalty%'
group by m.referee_id
order by utakmice_sa_penalom DESC
limit 1;