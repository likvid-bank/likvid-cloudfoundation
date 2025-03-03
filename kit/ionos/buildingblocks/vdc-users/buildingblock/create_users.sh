#!/bin/bash

# Enable best practices for error handling and debugging
set -o errexit  # Exit the script when any command fails
set -o errtrace # Trace errors in functions
set -o pipefail # Set the exit status of a pipe to the one that fails
set -o nounset  # Exit the script when using an undefined variable

# API credentials

first_login_passwrd="$IONOS_FIRST_LOGIN_PW"
token="$TOKEN_IONOS"
url="https://api.ionos.com/cloudapi/v6/um/users"

# Pagination parameters
limit=100
offset=0

# Extract list of user emails from MESH_USERS environment variable
users_list="$(echo "$MESH_USERS" | jq '.[].email')"

  # Create new users from the MESH_USERS list
  for new_user in $(echo "$MESH_USERS" | jq -c '.[]'); do
    new_email="$(echo "$new_user" | jq -r '.email')"
    #echo $new_email
    firstname="$(echo "$new_user" | jq -r '.firstName')"  
    lastname="$(echo "$new_user" | jq -r '.lastName')"
    
    #If the user does not exist, create them
    #echo $users_list
    # echo "$users_list" | grep -wq "$new_email"
      
    #    if echo "$users_list" | grep -q "^$new_email"; then
      echo "User $new_email  Creating..."
      password=$first_login_passwrd

      # Prepare payload for creating the user
      new_user_payload="{\"properties\": {\"firstname\": \"$firstname\", \"lastname\": \"$lastname\", \"email\": \"$new_email\", \"administrator\": false, \"password\": \"$password\", \"active\": true}}"

      # Make the POST request to create the user
      create_response=$(curl -s -w "%{http_code}" -X POST -H "Authorization: Basic $token" -H "Content-Type: application/json" -d "$new_user_payload" "$url")
      http_code=$(echo "$create_response" | tail -n 1)
      response_body=$(echo "$create_response" | sed '$d')

      # Output HTTP status code and response body for debugging
      echo "HTTP Status Code: $http_code"
      echo "Response: $response_body"

      # If user creation is successful (HTTP 202), check the activation status
      if [ "$http_code" -eq 202 ]; then
        echo "User $new_email created successfully, checking activation status..."
        user_id=$(echo "$response_body" | jq -r '.id')
        attempts=0
        max_attempts=5

        # Retry checking user activation status a few times
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

        # If activation fails after max attempts, notify the user
        if [ $attempts -eq $max_attempts ]; then
          echo "User $new_email could not be activated, maximum attempts reached."
        fi
      else
        # If user creation fails, output the status code
        echo "Error creating user $new_email. Status code: $http_code"
      fi
  done

