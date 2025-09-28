#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=periodic_table --tuples-only --no-align -c"

if [[ -z $1 ]]; then
  echo "Please provide an element as an argument."
  exit 0
fi

INPUT="$1"
if [[ $INPUT =~ ^[0-9]+$ ]]; then
  CONDITION="e.atomic_number = $INPUT"
else
  SAFE_INPUT=$(sed "s/'/''/g" <<< "$INPUT")
  CONDITION="e.symbol ILIKE '$SAFE_INPUT' OR e.name ILIKE '$SAFE_INPUT'"
fi

QUERY="SELECT e.atomic_number, e.name, e.symbol, t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius FROM elements e JOIN properties p USING(atomic_number) JOIN types t USING(type_id) WHERE $CONDITION ORDER BY e.atomic_number LIMIT 1;"

RESULT=$($PSQL "$QUERY" | sed '/^$/d')

if [[ -z $RESULT ]]; then
  echo "I could not find that element in the database."
  exit 0
fi

IFS='|' read -r ATOMIC_NUMBER NAME SYMBOL TYPE MASS MELT BOIL <<<"$RESULT"

echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELT celsius and a boiling point of $BOIL celsius."
