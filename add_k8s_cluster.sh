#/bin/bash

#password=Password#1
#server='10.237.198.35'

#credname=kubecreds02
#kubeusername=kubeuser
#kubeaddress=10.237.198.126
#kubename=powerpaas
#kubeport=6443

#USING KUBECTL WE GRAB THE PPDM DISCOVERY TOKEN FROM THE K8S CLUSTER
#kubepassword=$(kubectl get secret -n powerprotect $(kubectl get serviceaccount \
#-n powerprotect ppdm-discovery-serviceaccount -o jsonpath='{.secrets[0].name}') \
#-o jsonpath='{.data.token}') | base64 -d

#REFERENCING THE SECRETS IN VAULT FOR THE VARIABLE VALUES
password=$(echo $PASSWORD)
server=$(echo $SERVER)

kubepassword=$(echo $KUBEPASSWORD)
kubeusername=$(echo $KUBEUSERNAME)
kubeaddress=$(echo $KUBEADDRESS)
kubename=$(echo $KUBENAME)
kubeport=$(echo $KUBEPORT)
credname=$(echo $CREDNAME)


# LOGIN AND GET THE TOKEN
ppdm_login() {
request=$(curl -k --location --request POST https://${server}:8443/api/v2/login \
--header 'Content-Type: application/json' \
--data "{"\"username\"":"\"admin\"","\"password\"":"\"$password\""}")

token=$(echo $request | jq -r .access_token)
echo $token
}

# GET ALL OF THE CREDS FROM PPDM
getallcreds() {
echo " GETING ALL OF THE CREDS FROM PPDM"
existingcreds=$( curl -k \
  --request GET \
  --url "https://${server}:8443/api/v2/credentials?pageSize=100&page=1" \
  --header "Authorization: ${token}" )

echo "PRINTING OUT ALL THE CREDS FOUND"
echo ${existingcreds}
}

# CREATE A CRED IN THIS CASE FOR KUBERNETES
createkubecred() {
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
}

# GET ALL KUBERNETES-CLUSTERS FROM PPDM
getkubeclusters() {
existingkubeclusters=$(curl -k \
  --request GET \
  --url "https://${server}:8443/api/v2/kubernetes-clusters" \
  --header "Authorization: ${token}")

echo $existingkubeclusters
}

# RETRIEVE ALL INVENTORY SOURCES FROM PPDM
getallinventory() {
existinginventory=$(curl -k \
  --request GET \
  --url "https://${server}:8443/api/v2/inventory-sources?pageSize=100&page=1" \
  --header "Authorization: ${token}")

echo $existinginventory
}

# GET ALL CERTIFICATES
getallcerts() {
kubecertpayload=$(curl -k \
  --request GET \
  --url "https://${server}:8443/api/v2/certificates?type=HOST" \
  --header "Authorization: ${token}")
}

# GET THE KUBE CERT
getkubecert() {
  kubecertpayload=$(curl -k \
    --request GET \
    --url "https://${server}:8443/api/v2/certificates?host=${kubeaddress}&port=${kubeport}&type=HOST" \
    --header "Authorization: ${token}")
  echo $kubecertpayload
}


# FUNCTION TO CLEAN UP THE CERT AND THE CREDS
# DELETE THE KUBE CERT REQUIRES THE FUNCTION GETKUBECERT TO BE RAN FIRST
deletekubecert() {
kubecertid=$(echo $kubecertpayload | jq -r '.[] | .id')

curl -k \
  --request DELETE \
  --url "https://${server}:8443/api/v2/certificates/${kubecertid}" \
  --header "Authorization: ${token}"
}

# TRUST THE KUBERNETES CERTIFICATE
trustkubecert() {

payload=$(echo $kubecertpayload | jq -r --arg a "${kubeaddress}" '.[] | select(.host=$a) | .state = "ACCEPTED"')

kubecertid=$(echo $kubecertpayload | jq -r '.[] | .id')
echo $payload

curl -k \
  --request PUT \
  --url "https://${server}:8443/api/v2/certificates/${kubecertid}" \
  --header 'content-type: application/json' \
  --header "Authorization: ${token}" \
  --data "$payload"
}

# DELETE CREDENTIALS
deletecreds() {
credid=$1

  curl -k \
  --request DELETE \
  --url "https://${server}:8443/api/v2/credentials/${credid}" \
  --header "Authorization: ${token}"

echo "https://${server}:8443/api/v2/${credid}"
}

# ADD AN INVENTORY SOURCE, SPECIFIALLY A KUBE CLUSTER
addkubesource() {
getallids=$(echo $existingcreds | jq -r '.content[].id')
credid=$(echo $existingcreds | jq -r --arg KUBEUSERNAME "$KUBEUSERNAME" '.content[] | select(.name==$KUBEUSERNAME) | .id')

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
}


