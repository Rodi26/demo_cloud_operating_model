DEVOPS_ORG_ID=$(boundary scopes list -recursive -format=json | jq '.items[] | select( .name == "devops")' | jq -r '.id')
KUBE_PROJ_ID=$(boundary scopes list -scope-id=$DEVOPS_ORG_ID  -format=json | jq '.items[] | select( .name == "kubernetes")' | jq -r '.id')
BOUNDARY_CRED_STORE_ID=$(boundary credential-stores list -scope-id=$KUBE_PROJ_ID -format=json | jq '.items[] | select( .type == "vault")' | jq -r '.id')
BOUNDARY_CRED_LIB_ID=$(boundary credential-libraries list -credential-store-id=$BOUNDARY_CRED_STORE_ID -format=json | jq '.items[] | select( .name == "vault-cred-library")' | jq -r '.id')


BOUNDARY_CRED_STORE_TOKEN=$(vault token create \
    -no-default-policy=true \
    -policy="boundary-controller" \
    -orphan=true \
    -period=20m \
    -renewable=true \
    -format=json | jq -r '.auth | .client_token') && echo $BOUNDARY_CRED_STORE_TOKEN

boundary credential-stores update vault\
    -id $BOUNDARY_CRED_STORE_ID \
    -vault-token $BOUNDARY_CRED_STORE_TOKEN

KUBE_TARGET_ID=$(boundary targets list -scope-id=$KUBE_PROJ_ID -format=json | jq '.items[] | select( .name == "kubernetes-api")' | jq -r '.id')

BROKERED_KUBE_TOKEN=$(boundary targets authorize-session \
     -id $KUBE_TARGET_ID \
     -format json | jq -r '.item | .credentials[] | .secret | .decoded | .service_account_token') \
     && echo $BROKERED_KUBE_TOKEN

kubectl config set-context empty && kubectl config use-context empty