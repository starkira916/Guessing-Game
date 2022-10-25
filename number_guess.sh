#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
#random number generator
NUMBER=$(( $RANDOM % 1000 + 1 ))

#main menu
MAIN_MENU(){
echo Enter your username:
read USERNAME
CHECK_USERNAME=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME';")
if [[ -z $CHECK_USERNAME ]]
then
  #new user
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  #Insert new user
  INSERT_USERNAME=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME');")
  CHECK_USERNAME=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME';")
else
  #old user
  ATTEMPTS=$($PSQL "SELECT COUNT(*) FROM games_played WHERE user_id = $CHECK_USERNAME;")
  BEST_RECORD=$($PSQL "SELECT MIN(guess_total) FROM games_played WHERE user_id = $CHECK_USERNAME;")
  echo "Welcome back, $USERNAME! You have played $ATTEMPTS games, and your best game took $BEST_RECORD guesses."
fi
MAIN_GAME
}

MAIN_GAME(){
# ask to play the game
echo Guess the secret number between 1 and 1000:
#read guess
read GUESS
# initial attempt is 1
i=1
#loop until player gets the answer
while [[ $GUESS != $NUMBER ]]
do
if [[ ! $GUESS =~ ^[0-9]+$ ]]
then
  echo "That is not an integer, guess again:"
  read GUESS
else
  if [[ $GUESS > $NUMBER ]]
  then
  echo "It's lower than that, guess again:"
  read GUESS
  else
  echo "It's higher than that, guess again:"
  read GUESS
  fi
fi
i=$((i+1))
done
#final answer
echo "You guessed it in $i tries. The secret number was $NUMBER. Nice job!"
INSERT_TO_RANKINGS=$($PSQL "INSERT INTO games_played(guess_total,user_id) VALUES($i,$CHECK_USERNAME);")
}
MAIN_MENU
