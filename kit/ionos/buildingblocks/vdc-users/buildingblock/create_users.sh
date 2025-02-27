#!/bin/bash

token=$1
users=$2

# API URL
url="https://api.ionos.com/cloudapi/v6/um/users"

# Pagination-Parameter
limit=100
offset=0

# Liste aller existierenden User abrufen
users_list=$(echo "$users" | jq -r '.[].email')

while true; do
  # GET-Anfrage mit Pagination und Authentifizierung
  response=$(curl -s -H "Authorization: Basic $token" "$url?limit=$limit&offset=$offset")

  # Benutzer-IDs extrahieren
  user_ids=$(echo "$response" | jq -r '.items[].id')

  # Überprüfung, ob Nutzer bereits existieren
  for user_id in $user_ids; do
    user_details=$(curl -s -H "Authorization: Basic $token" "$url/$user_id")
    email=$(echo "$user_details" | jq -r '.properties.email')

    # Entferne existierende User aus der Liste
    users_list=$(echo "$users_list" | grep -v "^$email$" || true)
  done

  # Neue Benutzer erstellen
  for new_user in $(echo "$users" | jq -c '.[]'); do
    new_email=$(echo "$new_user" | jq -r '.email')
    firstname=$(echo "$new_user" | jq -r '.firstname')
    lastname=$(echo "$new_user" | jq -r '.lastname')

    if echo "$users_list" | grep -q "^$new_email$"; then
      echo "User $new_email does not exist yet. Creating..."
      password="NewPassword123"  # Hier könnte ein zufälliges Passwort generiert werden
      new_user_payload=$(cat <<EOF
{
  "properties": {
    "firstname": "$firstname",
    "lastname": "$lastname",
    "email": "$new_email",
    "administrator": false,
    "password": "$password",
    "active": true
  }
}
EOF
)
      create_response=$(curl -s -w "%{http_code}" -X POST -H "Authorization: Basic $token" -H "Content-Type: application/json" -d "$new_user_payload" "$url")
      http_code=$(echo "$create_response" | tail -n 1)
      response_body=$(echo "$create_response" | sed '$d')

      echo "HTTP Status Code: $http_code"
      echo "Response: $response_body"

      if [ "$http_code" -eq 202 ]; then
        echo "User $new_email created successfully, checking activation status..."
        user_id=$(echo "$response_body" | jq -r '.id')
        attempts=0
        max_attempts=5

        while [ $attempts -lt $max_attempts ]; do
          user_status=$(curl -s -H "Authorization: Basic $token" "$url/$user_id" | jq -r '.properties.active')
          if [ "$user_status" == "true" ]; then
            echo "User $new_email successfully activated."
            break
          else
            echo "User $new_email is not yet activated, retrying in 10 seconds..."
            sleep 10
            attempts=$((attempts + 1))
          fi
        done

        if [ $attempts -eq $max_attempts ]; then
          echo "User $new_email could not be activated, maximum attempts reached."
        fi
      else
        echo "Error creating user $new_email. Status code: $http_code"
      fi
    fi
  done

  count=$(echo "$response" | jq '.items | length')
  if [ "$count" -lt "$limit" ]; then
    break
  fi

  offset=$((offset + limit))
done
