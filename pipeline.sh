#!/usr/bin/env bash

#set -x
echo "Logging in to PPDM"
source ./add_k8s_cluster.sh
ppdm_login
echo "Creating the Kubernetes Credentials"
createkubecred
echo "Grabbing the Kubernetes Certificate"
getkubecert
echo "Trusting the Kubernetes Certificate"
trustkubecert
echo "Grabbing all Cred Information"
getallcreds
echo "Adding the Kubernetes Cluster to Asset Source"
addkubesource
