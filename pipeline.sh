#!/usr/bin/env bash
echo "Logging in to PPDM"
source ./add_k8s_cluster.sh \
login \
echo "Creating the Kubernetes Credentials"
createkubecred \
getkubecert \
trustkubecert
