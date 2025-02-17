#! /bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

#Menu principal
echo -e "\n~~~~~ SALON FERNANDEZ ~~~~~\n"
MAIN_MENU() {
  echo -e "\nWelcome to Salon Fernandez, how can I help you?\n"

  # Obtener la lista de servicios 
  SERVICES=$($PSQL "SELECT service_id, name FROM services;" | sed 's/ | /) /' | sed 's/^ *//')

  # Mostrar los servicios en el formato requerido
  echo "$SERVICES"

  #Pedir un input del cliente
  read SERVICE_ID_SELECTED
  
  # if not found 
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]] || [[ -z $($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED") ]]
  then
   echo -e "\nSorry we cannot help you with that"
   MAIN_MENU

  #Seguimos 
  else
   echo -e "\nGreat! You selected service #$SERVICE_ID_SELECTED"

   echo -e "\nWhat is your phone number?"
   read CUSTOMER_PHONE

   #if not found
   CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

   if [[ -z $CUSTOMER_ID ]]; 
   then
  # Cliente no encontrado, pedir nombre y agregarlo
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
   fi
   SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED" | sed -E 's/^ *| *$//g')
   CUSTOMER_FINAL_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id=$CUSTOMER_ID" | sed -E 's/^ *| *$//g')
   echo -e "OK,$CUSTOMER_FINAL_NAME ,at what time do you want the appointment?"
   read SERVICE_TIME
   INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
   echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_FINAL_NAME."

 
  fi
 
}

MAIN_MENU
