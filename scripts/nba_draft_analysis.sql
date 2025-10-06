/*
Name: Martin Mendoza
Updates:
    09/26/25 : Created file
               Added CREATE DATABASE command
    
    09/29/25 : Added CREATE TABLE commands for:
               - colleges
               - teams
               - players
               - draft_picks

               Added regions for database and table setup

               Added FOREIGN KEY constraints to:
               - players.college_id -> colleges.college_id
               - draft_picks.player_id -> players.player_id
               - draft_picks.team_id -> teams.team_id
               
               Imported draft_pick_history_cleaned.csv into draft_picks table
               - Inserted data into teams table
               - Inserted data into colleges table

    09/30/25 : Replaced dataset with a new one that includes player states for better EDA
               - Fixed existing tables and inserts to fit new dataset
               - Finished inserting data into players table

               Created a left join to connect players to their respective colleges and teams
               Asked AI to provide 10 EDA questions to answer
               Answered ALL easy and medium select statement questions

    10/01/25 : Completed all hard select statement questions

    10/05/25 : Exported a select query from each difficulty level to .csv files for tableau visualization
*/

/* #region DATABASE SETUP */

-- Switch to the 'mysql' system database to manage user privileges or server settings.
USE mysql;

-- Before making the database, ensures
-- that one doesn't already exist.
DROP DATABASE IF EXISTS nba_draft_analysis;

-- Creates the database.
CREATE DATABASE IF NOT EXISTS 
    nba_draft_analysis
    CHARSET='utf8mb4'
	COLLATE='utf8mb4_unicode_ci';

-- Specify which database we want to use.
USE nba_draft_analysis;
/* #endregion */

/* #region TABLE SETUP */
-- Before making the table, ensures
-- that one doesn't already exist.
DROP TABLE IF EXISTS colleges;

-- Creating a "colleges" table to store college information
CREATE TABLE colleges (
    college_id INT AUTO_INCREMENT PRIMARY KEY,
    college_name VARCHAR(100) UNIQUE
);

-- Before making the table, ensures
-- that one doesn't already exist.
DROP TABLE IF EXISTS teams;

-- Creating a "teams" table to store team information
CREATE TABLE teams (
    team_id INT AUTO_INCREMENT PRIMARY KEY,
    team_abbr VARCHAR(5) UNIQUE
);

-- Before making the table, ensures
-- that one doesn't already exist.
DROP TABLE IF EXISTS players;

-- Creating a "players" table to store player information
CREATE TABLE players (
    player_id VARCHAR(20) PRIMARY KEY,
    player_name VARCHAR(100),
    college_id INT,
    team_id INT,
    years_active INT,
    games INT,
    minutes_played INT,
    points INT,
    total_rebounds INT,
    assists INT,
    field_goal_percentage DECIMAL(5,2),
    three_point_percentage DECIMAL(5,2),
    free_throw_percentage DECIMAL(5,2),
    average_minutes_played DECIMAL(5,2),
    points_per_game DECIMAL(5,2),
    average_total_rebounds DECIMAL(5,2),
    average_assists DECIMAL(5,2),
    win_shares DECIMAL(6,2),
    win_shares_per_48_minutes DECIMAL(6,4),
    box_plus_minus DECIMAL(5,2),
    value_over_replacement DECIMAL(5,2),
    CONSTRAINT players_college_FK FOREIGN KEY (college_id)
        REFERENCES colleges(college_id),
    CONSTRAINT players_team_FK FOREIGN KEY (team_id)
        REFERENCES teams(team_id)
);

-- Before making the table, ensures
-- that one doesn't already exist.
DROP TABLE IF EXISTS drafts;

-- Creating a "drafts" table to store draft information
CREATE TABLE drafts (
    draft_id INT AUTO_INCREMENT PRIMARY KEY,
    player_id VARCHAR(20),
    draft_year INT,
    overall_pick INT,
    team_id INT,
    CONSTRAINT fk_player FOREIGN KEY (player_id) REFERENCES players(player_id),
    CONSTRAINT fk_team FOREIGN KEY (team_id) REFERENCES teams(team_id)
);
/* #endregion */

/* #region IMPORTING DATA */
-- Before making the table, ensures
-- that one doesn't already exist.
DROP TABLE IF EXISTS staging_nba;

-- Staging table
CREATE TABLE staging_nba (
    id INT,
    year INT,
    rank INT,
    overall_pick INT,
    team VARCHAR(50),
    player VARCHAR(100),
    college VARCHAR(150),
    years_active INT,
    games INT,
    minutes_played INT,
    points INT,
    total_rebounds INT,
    assists INT,
    field_goal_percentage DECIMAL(5,2),
    three_point_percentage DECIMAL(5,2),
    free_throw_percentage DECIMAL(5,2),
    average_minutes_played DECIMAL(5,2),
    points_per_game DECIMAL(5,2),
    average_total_rebounds DECIMAL(5,2),
    average_assists DECIMAL(5,2),
    win_shares DECIMAL(6,2),
    win_shares_per_48_minutes DECIMAL(6,4),
    box_plus_minus DECIMAL(5,2),
    value_over_replacement DECIMAL(5,2)
);

-- import .csv files
LOAD DATA INFILE 'C:/_data/_imports/nbaplayersdraft.csv'
INTO TABLE staging_nba
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id,year,rank,overall_pick,team,player,college,
 years_active,games,minutes_played,points,total_rebounds,assists,
 field_goal_percentage,three_point_percentage,free_throw_percentage,
 average_minutes_played,points_per_game,average_total_rebounds,
 average_assists,win_shares,win_shares_per_48_minutes,
 box_plus_minus,value_over_replacement);
/* #endregion */

/* #region INSERTING DATA */
    /* #region INSERTING TEAMS DATA */
    -- Find team abbreviations and names from draft_data and insert into teams table
    INSERT INTO teams (team_abbr)
    SELECT DISTINCT team
    FROM staging_nba
    WHERE team IS NOT NULL AND team <> '';

    -- Check inserted data
    Select * from teams
    ORDER BY team_id;

    -- Deleting all rows to re-insert with full names and correct abbreviations
    DELETE FROM teams;
    ALTER TABLE teams AUTO_INCREMENT = 1;

    -- Alter teams table to add full team names
    ALTER TABLE teams
    ADD COLUMN team_name VARCHAR(100);

    -- Insert abbreviations and their full names
    INSERT INTO teams (team_abbr, team_name)
    VALUES
    ('SAC','Sacramento Kings'),
    ('LAC','Los Angeles Clippers'),
    ('SAS','San Antonio Spurs'),
    ('MIA','Miami Heat'),
    ('CHH','Charlotte Hornets'),          -- original Hornets pre-relocation
    ('CHI','Chicago Bulls'),
    ('IND','Indiana Pacers'),
    ('DAL','Dallas Mavericks'),
    ('WSB','Washington Bullets'),
    ('MIN','Minnesota Timberwolves'),
    ('ORL','Orlando Magic'),
    ('NJN','New Jersey Nets'),
    ('BOS','Boston Celtics'),
    ('GSW','Golden State Warriors'),
    ('DEN','Denver Nuggets'),
    ('SEA','Seattle SuperSonics'),
    ('PHI','Philadelphia 76ers'),
    ('UTA','Utah Jazz'),
    ('POR','Portland Trail Blazers'),
    ('ATL','Atlanta Hawks'),
    ('PHO','Phoenix Suns'),
    ('CLE','Cleveland Cavaliers'),
    ('LAL','Los Angeles Lakers'),
    ('DET','Detroit Pistons'),
    ('MIL','Milwaukee Bucks'),
    ('NYK','New York Knicks'),
    ('HOU','Houston Rockets'),
    ('VAN','Vancouver Grizzlies'),
    ('TOR','Toronto Raptors'),
    ('WAS','Washington Wizards'),
    ('MEM','Memphis Grizzlies'),
    ('NOH','New Orleans Hornets'),
    ('CHA','Charlotte Hornets'),           -- current abbreviation (post-CHO)
    ('NOK','New Orleans/Oklahoma City Hornets'),
    ('OKC','Oklahoma City Thunder'),
    ('BRK','Brooklyn Nets'),
    ('CHO','Charlotte Hornets'),           -- older abbreviation (mid-era)
    ('NOP','New Orleans Pelicans');

    -- Check the inserted data
    -- Sorted by team_abbr for easier verification
    SELECT * FROM teams
    ORDER BY team_id;
    /* #endregion */

    /* #region INSERTING COLLEGES DATA */
    -- Adding colleges to the colleges table
    INSERT INTO colleges (college_name)
    SELECT DISTINCT college
    FROM staging_nba
    WHERE college IS NOT NULL AND college <> '';

    -- Check the inserted data
    SELECT * FROM colleges
    ORDER BY college_id;
    /* #endregion */

    /* #region INSERTING PLAYERS DATA */
    -- Insert players with valid IDs, names, and linked colleges
    INSERT INTO players (
        player_id,
        player_name,
        college_id,
        team_id,
        years_active,
        games,
        minutes_played,
        points,
        total_rebounds,
        assists,
        field_goal_percentage,
        three_point_percentage,
        free_throw_percentage,
        average_minutes_played,
        points_per_game,
        average_total_rebounds,
        average_assists,
        win_shares,
        win_shares_per_48_minutes,
        box_plus_minus,
        value_over_replacement
    )
    SELECT 
        CONCAT(year,'-',overall_pick) AS player_id, -- Use overall_pick to create unique player ids per draft pick
        player AS player_name,
        c.college_id,
        t.team_id,
        years_active,
        games,
        minutes_played,
        points,
        total_rebounds,
        assists,
        field_goal_percentage,
        three_point_percentage,
        free_throw_percentage,
        average_minutes_played,
        points_per_game,
        average_total_rebounds,
        average_assists,
        win_shares,
        win_shares_per_48_minutes,
        box_plus_minus,
        value_over_replacement
    FROM staging_nba s
    LEFT JOIN colleges c ON s.college = c.college_name -- get college_id
    LEFT JOIN teams t ON s.team = t.team_abbr; -- get team_id

    -- Check the inserted data
    SELECT * FROM players
    ORDER BY player_name;
    /* #endregion */

    /* #region INSERTING DRAFTS DATA */

-- Insert draft picks with valid player and team IDs
INSERT INTO drafts (player_id, draft_year, overall_pick, team_id)
SELECT 
    CONCAT(year,'-',overall_pick) AS player_id,
    year AS draft_year,
    overall_pick,
    t.team_id
FROM staging_nba s
LEFT JOIN teams t ON s.team = t.team_abbr;

-- Check the inserted data
SELECT * FROM drafts;
/* #endregion */
/* #endregion */

/* #region SELECT STATEMENTS*/
    /* #region EASY QUERIES */

    -- 1. Select player_name, team_id, and college_id for the first 10 players.
    SELECT player_name, team_id, college_id
    FROM players
    LIMIT 10;

    -- 2. Count the total number of players in the players table.
    SELECT COUNT(*) AS total_players
    FROM players;

    -- 3. Select player_name and points_per_game for all players, ordered by points_per_game descending.
    SELECT player_name, points_per_game AS ppg
    FROM players
    ORDER BY points_per_game DESC
    LIMIT 30;

    -- 4. Find the number of players for each team (just team_id or team_name).
    -- With team_id
    SELECT team_id, COUNT(*) AS players_drafted
    FROM players
    GROUP BY team_id;

    -- EXTRA: With team_name
    SELECT t.team_name, COUNT(*) AS players_drafted
    FROM players p
    JOIN teams t ON t.team_id = p.team_id
    GROUP BY t.team_id;
    /* #endregion */

    /* #region MEDIUM QUERIES */
    -- MEDIUM QUERIES

    -- 5. List the average points_per_game for players from each college, ordered by average points descending.
    SELECT c.college_name, ROUND(AVG(p.points_per_game), 2) AS ppg
    FROM players p
    JOIN colleges c on c.college_id = p.college_id
    GROUP BY c.college_id
    HAVING ppg > 0
    ORDER BY ppg DESC;

    -- EXTRA: Check which players contribute to the top college ppg
    SELECT c.college_name, p.player_name, p.points_per_game AS ppg
    FROM players p
    JOIN colleges c on c.college_id = p.college_id
    WHERE c.college_id = ( -- Instead of inputing college name
        SELECT college_id
        FROM players
        GROUP BY college_id
        ORDER BY AVG(points_per_game) DESC
        LIMIT 1
    )
    ORDER BY ppg DESC;

    -- 6. Find the top 5 players with the highest win_shares, including their team and college names.
    SELECT p.player_name, p.win_shares, t.team_name, c.college_name
    FROM players p
    JOIN teams t ON p.team_id = t.team_id
    JOIN colleges c ON p.college_id = c.college_id
    ORDER BY win_shares DESC
    LIMIT 5;

    -- 7. Count the number of players drafted in each year, ordered chronologically
    SELECT draft_year, COUNT(*) AS players_drafted
    FROM drafts
    GROUP BY draft_year
    ORDER BY draft_year;

    -- 8. Find the average minutes_played for players on each team.
    SELECT t.team_name, ROUND(AVG(p.minutes_played), 2) AS avg_minutes_played
    FROM players p
    JOIN teams t ON p.team_id = t.team_id
    GROUP BY t.team_id
    ORDER BY avg_minutes_played DESC;

    -- EXTRA: Check which players contribute to top team avg minutes played
    SELECT t.team_name, p.player_name, p.minutes_played
    FROM players p
    JOIN teams t ON p.team_id = t.team_id
    WHERE t.team_id = (
        SELECT team_id
        FROM players
        GROUP BY team_id
        ORDER BY AVG(minutes_played) DESC
        LIMIT 1
    )
    ORDER BY p.minutes_played DESC;
    /* #endregion */

    /* #region HARD QUERIES */



    -- HARD QUERIES

    -- 9. Find the player(s) with the maximum points_per_game in each draft year, including team and college.
    SELECT d.draft_year, p.player_name, p.points_per_game AS ppg, t.team_name, c.college_name
    FROM drafts d
    JOIN players p ON d.player_id = p.player_id
    JOIN teams t ON p.team_id = t.team_id
    JOIN colleges c ON p.college_id = c.college_id
    WHERE p.points_per_game = (
        SELECT MAX(points_per_game)
        FROM players p2
        JOIN drafts d2 ON p2.player_id = d2.player_id
        WHERE d2.draft_year = d.draft_year
    )
    GROUP BY draft_year;

    -- 10. Find the top 3 players with the highest points_per_game for each draft year, including their team and college.
    SELECT 
    d.draft_year,
    p.player_name,
    p.points_per_game AS ppg,
    t.team_name,
    c.college_name
    FROM drafts d
    JOIN players p ON d.player_id = p.player_id
    JOIN teams t ON p.team_id = t.team_id
    JOIN colleges c ON p.college_id = c.college_id
    WHERE (
        SELECT COUNT(*) 
        FROM players p2
        JOIN drafts d2 ON p2.player_id = d2.player_id
        WHERE d2.draft_year = d.draft_year
        AND p2.points_per_game > p.points_per_game
    ) < 3   -- top 3 per draft year
    ORDER BY d.draft_year, p.points_per_game DESC;
    /* #endregion */
/* #endregion */
