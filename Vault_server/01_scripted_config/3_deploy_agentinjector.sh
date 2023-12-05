#!/bin/bash

# Last update : August, 2022
# Author: cetin@hashicorp.com
# Description: Deploy a Pod that will access Vault secret, using K8s authentication method
# following this learn guide: https://learn.hashicorp.com/tutorials/vault/kubernetes-external-vault?in=vault/kubernetes

## Devwebapp with a service and endpoint to address an external Vault
vault kv put secret/devwebapp/config username='giraffe' password='salsa'
kubectl apply --filename=pod-devwebapp-through-service.yaml

vault policy write devwebapp - <<EOF
path "secret/data/devwebapp/config" {
  capabilities = ["read"]
}
EOF

vault write auth/kubernetes/role/devweb-app \
    bound_service_account_names=vault-auth \
    bound_service_account_namespaces=default \
    policies=devwebapp \
    ttl=24h

kubectl apply -f pod_with_vaultagent_injector.yaml

echo ""
echo "Run the command below to create a port-forwarding and then visit http://localhost:8080"
echo "   kubectl exec -it devwebapp-with-annotations -c app -- cat /vault/secrets/credentials.txt"
