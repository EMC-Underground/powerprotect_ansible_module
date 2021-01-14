#!/bin/bash

password=Password#1
server='10.237.198.35'

kubepassword=testpassword
kubeusername=kubeuser
credname=kubecreds


echo "{"\"admin\"":"\"$password\""}"
echo "visit:\"$password\""

# LOGIN AND GET THE TOKEN
request=$(curl -k --location --request POST https://${server}:8443/api/v2/login \
--header 'Content-Type: application/json' \
--data "{"\"username\"":"\"admin\"","\"password\"":"\"$password\""}")

token=$(echo $request | jq -r .access_token)

# GET ALL OF THE CREDS FROM PPDM
curl -k \
  --request GET \
  --url "https://${server}:8443/api/v2/credentials?pageSize=100&page=1" \
  --header "Authorization: ${token}"


# CREATE A CRED IN THIS CASE FOR KUBERNETES
json_payload=$( jq -n \
                  --arg kubepass "$kubepassword" \
                  --arg kubeuser "$kubeusername" \
                  --arg credname "$credname" \
                  --arg type "KUBERNETES" \
                  '{name: $credname, password: $kubepass, username: $kubeuser,
                  type: $type}' )

echo "Here is the JSON Payload $json_payload"

curl -k \
  --request POST \
  --url "https://${server}:8443/api/v2/credentials" \
  --header "Authorization: ${token}" \
  --header 'content-type: application/json' \
  --data "$json_payload"


