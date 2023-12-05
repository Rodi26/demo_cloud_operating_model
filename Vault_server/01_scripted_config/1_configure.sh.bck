#!/bin/bash

# Last update : August, 2022
# Author: cetin@hashicorp.com
# Description: Configure Vault Agent with Kubernetes
# following this learn guide: https://learn.hashicorp.com/tutorials/vault/agent-kubernetes

# This will configure a Kubernetes Service Account on minikube and the Kubernetes Auth Method on Vault.
# Pods running on the minikube K8s cluster will be able to authenticate using a Kubernetes Service Account Token.
# The pod will be able to retrieve static secrets from Vault, using the Vault Agent as an Init Container.

script_name=$(basename "$0")
version="0.1.0"

echo "Running $script_name - version $version"
echo ""

# Determine the Vault address
EXTERNAL_VAULT_ADDR="$(minikube ssh "dig +short host.docker.internal" | tr -d '\r')"

# Update vault address ENV variable for init container and kubernetes service endpoint
cat pod_with_vaultagent_initcontainer.tpl | \
   sed -e s/"EXTERNAL_VAULT_ADDR"/"$EXTERNAL_VAULT_ADDR"/ \
   > pod_with_vaultagent_initcontainer.yaml

cat external_vault.tpl | \
   sed -e s/"EXTERNAL_VAULT_ADDR"/"$EXTERNAL_VAULT_ADDR"/ \
   > external_vault.yaml

## Configuring Kubernetes
echo ">>> Configuring Kubernetes"
echo ""

### K8s - Create a Kubernetes service account
kubectl apply --filename vault_auth_service_account.yaml

### K8s - Create a Kubernetes config map
kubectl create --filename pod_with_vaultagent_initcontainer_configmap.yaml

### K8s - Create a Kubernetes Service and Endpoint to refer Vault
kubectl apply --filename external_vault.yaml

### K8s - Deploy Vault Agent Injector

#### Label namespace to ensure Vault agent webhook works
kubectl label namespace default vault.hashicorp.com/agent-webhook=enabled

#### Deploy Vault Agent Injector
helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo update
helm install vault hashicorp/vault \
  --set "injector.externalVaultAddr=http://external-vault:8200"

## Configuring Vault
echo ""
echo ">>> Configuring Vault"
echo ""

### collect kubernetes information for service account vault-auth

SA_SECRET_NAME="$(kubectl get secrets --output=json \
    | jq -r '.items[].metadata | select(.name|startswith("vault-auth-")).name')"

SA_JWT_TOKEN="$(kubectl get secret $SA_SECRET_NAME \
    --output 'go-template={{ .data.token }}' | base64 --decode)"

SA_CA_CRT="$(kubectl config view --raw --minify --flatten \
    --output 'jsonpath={.clusters[].cluster.certificate-authority-data}' | base64 --decode)"

K8S_HOST="$(kubectl config view --raw --minify --flatten \
    --output 'jsonpath={.clusters[].cluster.server}')"

### Configure Kubernetes Auth Method

vault auth enable kubernetes

vault write auth/kubernetes/config \
     token_reviewer_jwt="$SA_JWT_TOKEN" \
     kubernetes_host="$K8S_HOST" \
     kubernetes_ca_cert="$SA_CA_CRT" \
     issuer="https://kubernetes.default.svc.cluster.local"

### Create a role for Kubernetes Auth Method and the associated policy

vault policy write myapp-kv-ro vault_app_policy.hcl

vault write auth/kubernetes/role/example \
     bound_service_account_names=vault-auth \
     bound_service_account_namespaces=default \
     policies=myapp-kv-ro \
     ttl=1h
