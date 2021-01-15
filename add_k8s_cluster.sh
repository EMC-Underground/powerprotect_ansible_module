#!/bin/bash

password=Password#1
server='10.237.198.35'

kubepassword="eyJhbGciOiJSUzI1NiIsImtpZCI6IkF5M2dFYWxxY19rQmNQc2o5a2xGQktXWVB0dWtCRXl4cklwVXpCcVRiTFUifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJwb3dlcnByb3RlY3QiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlY3JldC5uYW1lIjoicHBkbS1kaXNjb3Zlcnktc2VydmljZWFjY291bnQtdG9rZW4tNHg5Z3giLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC5uYW1lIjoicHBkbS1kaXNjb3Zlcnktc2VydmljZWFjY291bnQiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC51aWQiOiJjZGY1M2ZkZC1hMmJkLTQ2NzctODc4NS01NTY1NzM0NWMwYTciLCJzdWIiOiJzeXN0ZW06c2VydmljZWFjY291bnQ6cG93ZXJwcm90ZWN0OnBwZG0tZGlzY292ZXJ5LXNlcnZpY2VhY2NvdW50In0.BR9OE_izxq3Y1Qf9loaghJPj5BK55RqAUk5UHLqzZpO_JygQS1dcCKNMDpF9busBKOF4eQ_DKowbDxJLgHKl8Ikz6waCULL3dYyiHSu2okseXppF4kcOtvoM4_WruLhvltrDpU8DXaM5c_sjz7TPqtecvZAoS6pu_u0x2plahBxyV5uLpEBcEyZoemHyuPSxdBWDT68i9vZX-MzsfRroYKgPNmak4144YClr5OaXTNg55QtQEGQbWX-UoIZwLvDzJ8OaauuskhsOdo4Uf75WLYBic-0bfYbDuSAikrWkjq1bCMaCecEWwZH_8cM35eWuZ9fRFaZ8ukwjr2C5oo03Hw"
kubeusername=kubeuser
credname=kubecreds02

kubeaddress=10.237.198.126
kubename=powerpaas



# LOGIN AND GET THE TOKEN
request=$(curl -k --location --request POST https://${server}:8443/api/v2/login \
--header 'Content-Type: application/json' \
--data "{"\"username\"":"\"admin\"","\"password\"":"\"$password\""}")

token=$(echo $request | jq -r .access_token)

# GET ALL OF THE CREDS FROM PPDM
echo " GETING ALL OF THE CREDS FROM PPDM"
existingcreds=$( curl -k \
  --request GET \
  --url "https://${server}:8443/api/v2/credentials?pageSize=100&page=1" \
  --header "Authorization: ${token}" )

echo "PRINTING OUT ALL THE CREDS FOUND"
echo ${existingcreds}

# CREATE A CRED IN THIS CASE FOR KUBERNETES
json_payload=$( jq -n \
                  --arg kubepass "$kubepassword" \
                  --arg kubeuser "$kubeusername" \
                  --arg credname "$credname" \
                  --arg type "KUBERNETES" \
                  --arg method "TOKEN" \
                  '{name: $credname, password: $kubepass, username: $kubeuser,
                  type: $type, method: $method}' )

echo "Here is the JSON Payload $json_payload"

curl -k \
  --request POST \
  --url "https://${server}:8443/api/v2/credentials" \
  --header "Authorization: ${token}" \
  --header 'content-type: application/json' \
  --data "$json_payload"

# GET ALL KUBERNETES-CLUSTERS FROM PPDM
existingkubeclusters=$(curl -k \
  --request GET \
  --url "https://${server}:8443/api/v2/kubernetes-clusters" \
  --header "Authorization: ${token}")

echo $existingkubeclusters

# RETRIEVE ALL INVENTORY SOURCES FROM PPDM
existinginventory=$(curl -k \
  --request GET \
  --url "https://${server}:8443/api/v2/inventory-sources?pageSize=100&page=1" \
  --header "Authorization: ${token}")

echo $existinginventory

# GET ALL CERTIFICATES
kubecertpayload=$(curl -k \
  --request GET \
  --url "https://${server}:8443/api/v2/certificates?type=HOST" \
  --header "Authorization: ${token}")

# TRUST THE KUBERNETES CERTIFICATE
payload=$(echo $kubecertpayload | jq -r --arg a "$server" '.content[] | select(.host==$a) | .state = "ACCEPTED"')
echo $payload

curl -k \
  --request PUT \
  --url "https://${server}:8443/api/v2/certificates" \
  --header 'content-type: application/json' \
  --header "Authorization: ${token}" \
  --data "$payload"

# DELETE CREDENTIALS
curl -k \
  --request DELETE \
  --url "https://${server}:8443/api/v2/${credid}" \
  --header "Authorization: ${token}"

# ADD AN INVENTORY SOURCE, SPECIFIALLY A KUBE CLUSTER
getallids=$(echo $existingcreds | jq -r '.content[].id')
credid=$(echo $existingcreds | jq -r '.content[] | select(.type=="KUBERNETES") | .id')

json_payload=$( jq -n \
                  --arg kubeaddress "$kubeaddress" \
                  --arg kubename "$kubename" \
                  --arg type "KUBERNETES" \
                  --arg port "6443" \
                  --arg credid "$credid" \
                  '{address: $kubeaddress, name: $kubename, type: $type, port: $port, credentials:{id: $credid}}' )

echo $json_payload

curl -k \
  --request POST \
  --url "https://${server}:8443/api/v2/inventory-sources" \
  --header "Authorization: ${token}" \
  --header 'content-type: application/json' \
  --data "${json_payload}"


