#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=number_guess --tuples -c"

# Initialize variables
SECRETNUM=1001
NUMBER_OF_GUESSES=1
BEST_GAME=1000
GAMES_PLAYED=0

# Create a random number for the guessing game 
NUM=$(( $RANDOM % 1000 +1))
#echo $NUM
echo -e "\nEnter your username:"
read USERNAME

# Check to see if the username is an existing user
EXISTING_USER=$($PSQL "select * from game where username='$USERNAME'")
if [[ -z $EXISTING_USER ]]
then
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
else
  while IFS="|" read UNAME NO_GAMES BEST_SCORE
  do
    echo -e "\nWelcome back, $(echo $USERNAME)! You have played $(echo $NO_GAMES) games, and your best game took $(echo $BEST_SCORE) guesses."
    BEST_GAME=$BEST_SCORE
    GAMES_PLAYED=$NO_GAMES
  done <<< "$(echo "$EXISTING_USER")" 
fi
    
# Read input until a numeric number is entered
echo -e "\nGuess the secret number between 1 and 1000:"
read SECRETNUM
while [[ ! $SECRETNUM =~ ^[0-9]+$ ]]
do
  echo -e "\nThat is not an integer, guess again:"
  read SECRETNUM
done

# While loop is repeated as long as the user han not guessed the correct number
while (( $SECRETNUM != $NUM ))
do
  if (( $SECRETNUM > $NUM ))
  then
    echo -e "\nIt's lower than that, guess again:"
    ((NUMBER_OF_GUESSES++))
  else
    echo -e "\nIt's higher than that, guess again:"
    ((NUMBER_OF_GUESSES++))
  fi
  read SECRETNUM 
  while [[ ! $SECRETNUM =~ ^[0-9]+$ ]]
  do
    echo -e "\nThat is not an integer, guess again:"
    read SECRETNUM
  done
done

echo -e "\nYou guessed it in $(echo $NUMBER_OF_GUESSES) tries. The secret number was $(echo $NUM). Nice job!"
if [[ -z $EXISTING_USER ]]
then
  INSERT_RESULT=$($PSQL "insert into game values('$USERNAME', 1, $NUMBER_OF_GUESSES)")
else
  if (( $BEST_GAME > $NUMBER_OF_GUESSES ))
  then
    BEST_GAME=$NUMBER_OF_GUESSES
  fi
  (( GAMES_PLAYED++ ))
  UPDATE_RESULT=$($PSQL "update game set games_played=$GAMES_PLAYED, best_game=$BEST_GAME where username='$USERNAME'")
fi

