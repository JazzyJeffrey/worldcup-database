#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# Function to get team_id
get_team_id() {
  echo $($PSQL "SELECT team_id FROM teams WHERE name='$1';")
}

# Insert unique teams into the teams table
echo "Inserting teams..."
while IFS=',' read -r year round winner opponent winner_goals opponent_goals
do
  # Skip the header line
  if [[ $year != "year" ]]
  then
    # Insert winner
    if [[ -z $(get_team_id "$winner") ]]
    then
      echo $($PSQL "INSERT INTO teams(name) VALUES('$winner');")
    fi

    # Insert opponent
    if [[ -z $(get_team_id "$opponent") ]]
    then
      echo $($PSQL "INSERT INTO teams(name) VALUES('$opponent');")
    fi
  fi
done < games.csv

# Insert games into the games table
echo "Inserting games..."
while IFS=',' read -r year round winner opponent winner_goals opponent_goals
do
  # Skip the header line
  if [[ $year != "year" ]]
  then
    # Get team_ids
    winner_id=$(get_team_id "$winner")
    opponent_id=$(get_team_id "$opponent")

    # Insert game
    echo $($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($year, '$round', $winner_id, $opponent_id, $winner_goals, $opponent_goals);")
  fi
done < games.csv
