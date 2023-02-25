#!/bin/bash
PSQL="psql --user=freecodecamp --dbname=number_guess -t --no-align --tuples-only -c"

NUMBER=$(( $RANDOM % 1000 + 1))

echo "Enter your username:"
read USERNAME

TRUNCATE_TRIES_TABLE=$($PSQL "TRUNCATE tries")
RESTART_TRIES_TABLE=$($PSQL "ALTER SEQUENCE tries_guessing_seq RESTART")

NUMBER=$(( $RANDOM % 1000 + 1))
USERNAME_AVAIL
USERNAME_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
if [[ -z $USERNAME_ID ]]
then
  INSERT_USERNAME_IN_DB=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id = $USERNAME_ID")
  BEST_GAME=$($PSQL "SELECT MIN(guesses) FROM games WHERE user_id = $USERNAME_ID ")
  if [[ -z $GAMES_PLAYED ]]
  then
    GAMES_PLAYED=0
    BEST_GAME=0
  fi
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

echo "Guess the secret number between 1 and 1000:"
read GUESS
INSERT_TRY=$($PSQL "INSERT INTO tries(insert_try) VALUES('Try inserted')")
while [[ $GUESS -ne $NUMBER ]]
do
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    read GUESS
    INSERT_TRY=$($PSQL "INSERT INTO tries(insert_try) VALUES('Try inserted')")
    continue
  fi
  if [[ $GUESS -gt $NUMBER ]]
  then
    echo "It's lower than that, guess again:"
    read GUESS
    INSERT_TRY=$($PSQL "INSERT INTO tries(insert_try) VALUES('Try inserted')")
    continue
  else
    echo "It's higher than that, guess again:"
    read GUESS
    INSERT_TRY=$($PSQL "INSERT INTO tries(insert_try) VALUES('Try inserted')")
    continue
  fi
done
TOTAL_TRIES=$($PSQL "SELECT MAX(guessing) FROM tries")
INSERT_FINISHED_GAME=$($PSQL "INSERT INTO games(user_id, guesses) VALUES($USERNAME_ID, $TOTAL_TRIES)")
echo "You guessed it in $TOTAL_TRIES tries. The secret number was $NUMBER. Nice job!"