#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
SECRET_NUMBER=$(( $RANDOM % 1000 + 1 ))

echo "Enter your username:"
read USERNAME

# Verificar si el usuario ya existe
RETURNING_USER=$($PSQL "SELECT username FROM users WHERE username = '$USERNAME'")
if [[ -z $RETURNING_USER ]]
then
  # Si no existe, insertar nuevo usuario
  INSERT_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else 
  # Si existe, obtener estadísticas
  GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games INNER JOIN users ON games.user_id = users.user_id WHERE username = '$USERNAME'")
  BEST_GAME=$($PSQL "SELECT MIN(guesses) FROM games INNER JOIN users ON games.user_id = users.user_id WHERE username = '$USERNAME'")
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# Iniciar juego
echo "Guess the secret number between 1 and 1000:"
read GUESS
TRIES=1

# Bucle del juego
while [[ $GUESS -ne $SECRET_NUMBER ]]
do
  # Verificar si es un número entero
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  else
    # Comprobar si es mayor o menor
    if [[ $GUESS -gt $SECRET_NUMBER ]]
    then
      echo "It's lower than that, guess again:"
    elif [[ $GUESS -lt $SECRET_NUMBER ]]
    then
      echo "It's higher than that, guess again:"
    fi
    TRIES=$((TRIES+1))
  fi
  read GUESS
done

# Mensaje de victoria
echo "You guessed it in $TRIES tries. The secret number was $SECRET_NUMBER. Nice job!"

# Obtener user_id
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")

# Guardar el juego en la base de datos
INSERT_GAME=$($PSQL "INSERT INTO games(user_id, guesses) VALUES($USER_ID, $TRIES)")
