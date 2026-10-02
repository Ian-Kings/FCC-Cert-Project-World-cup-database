#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

echo $($PSQL "TRUNCATE TABLE games, teams")
 
# Read the CSV once and build two batched statements (2 DB calls total)
TEAM_VALUES=""
GAME_VALUES=""
 
while IFS=',' read -r YEAR ROUND WINNER OPPONENT WG OG
do
  if [[ $YEAR == "year" ]]; then continue; fi
 
  W=${WINNER//\'/\'\'}
  O=${OPPONENT//\'/\'\'}
 
  TEAM_VALUES+="('$W'),('$O'),"
  GAME_VALUES+="($YEAR,'$ROUND',(SELECT team_id FROM teams WHERE name='$W'),(SELECT team_id FROM teams WHERE name='$O'),$WG,$OG),"
done < games.csv
 
echo $($PSQL "INSERT INTO teams(name) VALUES ${TEAM_VALUES%,} ON CONFLICT (name) DO NOTHING")
echo $($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES ${GAME_VALUES%,}")