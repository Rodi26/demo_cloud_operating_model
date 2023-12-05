#!/bin/bash

# Last update : August, 2022
# Author: cetin@hashicorp.com
# Description: Deploy a Pod that will access Vault secret, using K8s authentication method
# following this learn guide: https://learn.hashicorp.com/tutorials/vault/agent-kubernetes

script_name=$(basename "$0")
version="0.1.0"

echo "Running $script_name - version $version"
echo ""

### create a sample static secret

echo ""
echo ">>> Generate a static secret and deploy a Pod that will access,"
echo "    using K8s authentication method and Vault Agent as Init Container."
echo ""

vault kv put secret/myapp/config \
      username='appuser' \
      password='dbbb' \
      ttl='30s'

echo ""

# Deploy the Vault Agent example application
kubectl apply --filename pod_with_vaultagent_initcontainer.yaml

echo ""
echo "Run the command below to create a port-forwarding and then visit http://localhost:8080"
echo "   kubectl port-forward pod/pod-with-vaultagent-initcontainer 8080:80"
