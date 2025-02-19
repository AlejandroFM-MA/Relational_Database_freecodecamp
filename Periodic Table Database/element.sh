#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# Comprobar si hay argumento
if [[ -z $1 ]]; then
  echo "Please provide an element as an argument."
  exit 0
fi

# Comprobar si es un número
if [[ $1 =~ ^[0-9]+$ ]]; then
  CONDITION="e.atomic_number=$1"
# Si no es número, puede ser símbolo o nombre
else
  CONDITION="e.symbol='$1' OR e.name='$1'"
fi

# Ejecutar consulta
QUERY="
  SELECT e.atomic_number, e.name, e.symbol, t.type, p.atomic_mass , p.melting_point_celsius, p.boiling_point_celsius
  FROM elements e
  JOIN properties p ON e.atomic_number = p.atomic_number
  JOIN types t ON p.type_id = t.type_id
  WHERE $CONDITION
"

ELEMENT_INFO=$($PSQL "$QUERY")

# Verificar si existe el elemento
if [[ -z $ELEMENT_INFO ]]; then
  echo "I could not find that element in the database."
else
  IFS="|" read ATOMIC_NUMBER NAME SYMBOL TYPE MASS MELTING BOILING <<< "$ELEMENT_INFO"
  echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING celsius and a boiling point of $BOILING celsius."
fi
