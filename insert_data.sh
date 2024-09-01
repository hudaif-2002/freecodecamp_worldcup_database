#!/bin/bash

# Define the PSQL command
if [[ $1 == "test" ]]; then
  PSQL="psql --username=postgres --dbname=worldcuptest --no-align --tuples-only -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup --no-align --tuples-only -c"
fi

# Clear existing data from the tables
$PSQL "TRUNCATE TABLE games, teams;"

# Insert unique teams into the teams table
# Extract unique team names from the CSV
cat games.csv | tail -n +2 | cut -d',' -f3,4 | tr -d '"' | sort | uniq | while IFS=, read WINNER OPPONENT; do
  if [[ -n "$WINNER" && "$WINNER" != "winner" ]]; then
    $PSQL "INSERT INTO teams(name) VALUES ('$WINNER') ON CONFLICT (name) DO NOTHING;"
  fi
  if [[ -n "$OPPONENT" && "$OPPONENT" != "opponent" ]]; then
    $PSQL "INSERT INTO teams(name) VALUES ('$OPPONENT') ON CONFLICT (name) DO NOTHING;"
  fi
done

# Insert data into games table
cat games.csv | tail -n +2 | while IFS=, read year round winner opponent winner_goals opponent_goals; do
  # Get the team IDs
  WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$winner';")
  OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$opponent';")
  
  # Insert into games table
  $PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES ($year, '$round', $WINNER_ID, $OPPONENT_ID, $winner_goals, $opponent_goals);"
done
