#!/usr/bin/env ash

echo "Logging in to PPDM"
source ./add_k8s_cluster.sh
login
echo "Creating the Kubernetes Credentials"
createkubecred
echo "Grabbing the Kubernetes Certificate"
getkubecert
echo "Trusting the Kubernetes Certificate"
trustkubecert
