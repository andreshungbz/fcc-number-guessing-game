#!/bin/bash

# PSQL query variable
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# generate random secret number to guess and store its value
SECRET_NUMBER=$((1 + $RANDOM % 1000))
echo $SECRET_NUMBER

# prompt player for their username and read the input
echo "Enter your username:"
read USERNAME

# check for username in database
USERNAME_RESULT=$($PSQL "SELECT username, games_played, best_game FROM players WHERE username='$USERNAME'")

# display welcome back message if the user already exists in the database
if [[ $USERNAME_RESULT ]]
then
  echo $USERNAME_RESULT | while IFS="|" read USER GAMES_PLAYED BEST_GAME
  do
    echo "Welcome back, $USER! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  done
# welcome new user if the user does not exist in the database
else
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  # add user to the database
  INSERT_USER_RESULT=$($PSQL "INSERT INTO players(username) VALUES('$USERNAME')")
fi

# create number of guesses variable
NUMBER_OF_GUESSES=0

# prompt user for guess
echo "Guess the secret number between 1 and 1000:"
read GUESS
((NUMBER_OF_GUESSES++))

# compare guess to secret number
while [[ $GUESS != $SECRET_NUMBER ]]
do
# reprompt if guess is not a number
if [[ ! $GUESS =~ ^[0-9]+$ ]]
then
  echo "That is not an integer, guess again:"
  read GUESS
  ((NUMBER_OF_GUESSES++))
# if guess is less than the secret number
elif [[ $GUESS -lt $SECRET_NUMBER ]]
then
  echo "It's higher than that, guess again:"
  read GUESS
  ((NUMBER_OF_GUESSES++))
# if guess is more than the secret number
else
  echo "It's lower than that, guess again:"
  read GUESS
  ((NUMBER_OF_GUESSES++))
fi
done

# successful guess message
echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"

# update user stats in database
# increment games played
UPDATE_GAMES_RESULT=$($PSQL "UPDATE players SET games_played=games_played+1 WHERE username='$USERNAME'")

# update best game if number of guesses is lower
CURRENT_BEST_GAME=$($PSQL "SELECT best_game FROM players WHERE username='$USERNAME'")
if [[ $NUMBER_OF_GUESSES -lt $CURRENT_BEST_GAME ]]
then
  UPDATE_BEST_RESULT=$($PSQL "UPDATE players SET best_game=$NUMBER_OF_GUESSES WHERE username='$USERNAME'")
fi