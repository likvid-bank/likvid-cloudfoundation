locals {
  admins  = { for user in var.users : user.username => user if contains(user["roles"], "admin") }
  editors = { for user in var.users : user.username => user if contains(user["roles"], "user") }
  readers = { for user in var.users : user.username => user if contains(user["roles"], "reader") }
  all_users = [
    for user in concat(values(local.admins), values(local.editors), values(local.readers)) : {
      firstname = user.firstName
      lastname  = user.lastName
      email     = user.email
    }
  ]
}

output "test" {
  value = jsonencode(local.all_users)
}

resource "null_resource" "create_user" {
  triggers = {
    users = jsonencode(local.all_users)
    token = var.token
  }

  provisioner "local-exec" {
    when    = create
    command = <<EOT

#!/bin/bash
set -eo
set -xv

# API URL
url="https://api.ionos.com/cloudapi/v6/um/users"

# Pagination parameters
limit=100
offset=0

# Retrieve a list of all existing users
users_list=$(echo '${self.triggers.users}' | jq -r '.[].email')

while true; do
  # GET request with pagination and authentication
  response=$(curl -s -H "Authorization: Basic ${self.triggers.token}" "$url?limit=$limit&offset=$offset")

  # Extract user IDs
  user_ids=$(echo "$response" | jq -r '.items[].id')

  # Check if users already exist
  for user_id in $user_ids; do
    user_details=$(curl -s -H "Authorization: Basic ${self.triggers.token}" "$url/$user_id")
    email=$(echo "$user_details" | jq -r '.properties.email')

    # Remove existing users from the list
    users_list=$(echo "$users_list" | grep -v "^$email$" || true)
  done

  # Create new users
  for new_user in $(echo "$users" | jq -c '.[]'); do
    new_email=$(echo "$new_user" | jq -r '.email')
    firstname=$(echo "$new_user" | jq -r '.firstname')
    lastname=$(echo "$new_user" | jq -r '.lastname')

    if echo "$users_list" | grep -q "^$new_email$"; then
      echo "User $new_email does not exist yet. Creating..."
      password="NewPassword123"  # A random password could be generated here
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

      create_response=$(curl -s -w "\%%{http_code}" -X POST -H "Authorization: Basic ${self.triggers.token}" -H "Content-Type: application/json" -d "$new_user_payload" "$url")
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

EOT
  }
}
