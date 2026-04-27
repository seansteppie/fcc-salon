#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
SERVICES_SELECT="SELECT service_id, name FROM services"
SERVICES_COUNT="SELECT COUNT(*) FROM services"
echo -e "\n~~~~~ My Salon ~~~~~\n"

main_menu() {
  if [[ $1 ]]; then
    echo -e "\n$1"
  else
    echo -e "Welcome to My Salon, how can I help you?\n"
  fi
  # maxid=$($PSQL "$SERVICES_COUNT" | sed 's/[^0-9]//g')
  SERVICE_ID_SELECTED=0

  echo "$($PSQL "$SERVICES_SELECT")" | while read SERVICE_ID bar SERVICE_NAME; do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
  read SERVICE_ID_SELECTED
  if [[ $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]; then
    add_service
  else
    bad_input
  fi
}

add_service() {
  SERVICE_ID=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  if [[ -z $SERVICE_ID ]]; then
    bad_input
  fi
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  CUSTOMER_NAME="$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'" | sed 's/^ *| *$//g')"
  if [[ -z $CUSTOMER_NAME ]]; then
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    CUSTOMER_NAME=$(echo $CUSTOMER_NAME | sed 's/^ *| *$//g')
    INSERT_CUSTOMER_RETURN=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
  fi
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'" | sed 's/[^0-9]//g')
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED" | sed 's/ //g')
  echo "What time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
  read SERVICE_TIME
  INSERT_SERVICE_RETURN="$($PSQL "INSERT INTO appointments(customer_id, time, service_id) VALUES($CUSTOMER_ID, '$SERVICE_TIME', $SERVICE_ID_SELECTED)")"
  echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
}

bad_input() {
  main_menu "I could not find that service. What would you like today?"
}
main_menu
