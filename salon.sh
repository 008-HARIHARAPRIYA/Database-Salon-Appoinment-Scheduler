#!/bin/bash

echo "~~~~~ MY SALON ~~~~~"
echo ""
echo "Welcome to My Salon, how can I help you?"
echo ""

# Display services until valid selection
while true; do
  # Display list of services
  psql --username=freecodecamp --dbname=salon -t -c "SELECT service_id, name FROM services ORDER BY service_id;" | sed -e 's/|//' | awk '{if (NF > 0) print $1") "$2}'
  
  # Read service selection
  read SERVICE_ID_SELECTED
  
  # Check if service exists
  SERVICE_EXISTS=$(psql --username=freecodecamp --dbname=salon -t -c "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED;" 2>/dev/null | xargs)
  
  if [[ ! -z "$SERVICE_EXISTS" ]]; then
    break
  else
    echo ""
    echo "I could not find that service. What would you like today?"
    echo ""
  fi
done

echo ""

# Get the service name
SERVICE_NAME=$(psql --username=freecodecamp --dbname=salon -t -c "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED;" | xargs)

# Ask for phone number
echo "What's your phone number?"
read CUSTOMER_PHONE

# Check if customer exists
CUSTOMER_ID=$(psql --username=freecodecamp --dbname=salon -t -c "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE';" 2>/dev/null | xargs)

if [[ -z "$CUSTOMER_ID" ]]; then
  # Customer doesn't exist, ask for name
  echo ""
  echo "I don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME
  
  # Insert new customer
  psql --username=freecodecamp --dbname=salon -c "INSERT INTO customers (phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME');" > /dev/null
  
  # Get the newly created customer ID
  CUSTOMER_ID=$(psql --username=freecodecamp --dbname=salon -t -c "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE';" | xargs)
else
  # Customer exists, get their name
  CUSTOMER_NAME=$(psql --username=freecodecamp --dbname=salon -t -c "SELECT name FROM customers WHERE customer_id = $CUSTOMER_ID;" | xargs)
fi

echo ""

# Ask for appointment time
echo "What time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
read SERVICE_TIME

# Insert appointment
psql --username=freecodecamp --dbname=salon -c "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');" > /dev/null

echo ""
echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
