kubectl create -f - <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: vault
  namespace: vault
---
apiVersion: v1
kind: Secret
metadata:
  name: vault
  namespace: vault
  annotations:
    kubernetes.io/service-account.name: vault
type: kubernetes.io/service-account-token
EOF

kubectl create -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: k8s-full-secrets-abilities-with-labels
rules:
- apiGroups: [""]
  resources: ["namespaces"]
  verbs: ["get"]
- apiGroups: [""]
  resources: ["serviceaccounts", "serviceaccounts/token"]
  verbs: ["create", "update", "delete"]
- apiGroups: ["rbac.authorization.k8s.io"]
  resources: ["rolebindings", "clusterrolebindings"]
  verbs: ["create", "update", "delete"]
- apiGroups: ["rbac.authorization.k8s.io"]
  resources: ["roles", "clusterroles"]
  verbs: ["bind", "escalate", "create", "update", "delete"]
EOF

kubectl create -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: vault-token-creator-binding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: k8s-full-secrets-abilities-with-labels
subjects:
- kind: ServiceAccount
  name: vault
  namespace: vault
EOF

KUBE_VAULT_SECRET=$(kubectl get secret -n vault vault -o json | jq -r '.data')
KUBE_CA_CRT=$(echo $KUBE_VAULT_SECRET | jq -r '."ca.crt"' | base64 -d)
KUBE_VAULT_TOKEN=$(echo $KUBE_VAULT_SECRET | jq -r '.token' | base64 -d)

vault secrets enable kubernetes
vault write -f kubernetes/config \
    kubernetes_host=$KUBE_API_URL \
    kubernetes_ca_cert=$KUBE_CA_CRT \
    service_account_jwt=$KUBE_VAULT_TOKEN

vault write kubernetes/roles/auto-managed-sa-and-role \
allowed_kubernetes_namespaces="*" \
token_default_ttl="10m" \
generated_role_rules='{"rules":[{"apiGroups":[""],"resources":["pods"],"verbs":["list"]}]}'

vault write kubernetes/creds/auto-managed-sa-and-role \
    kubernetes_namespace=default

kubectl get serviceaccount

vault policy write boundary-controller - <<EOF
 path "auth/token/lookup-self" {
   capabilities = ["read"]
 }

 path "auth/token/renew-self" {
   capabilities = ["update"]
 }

 path "auth/token/revoke-self" {
   capabilities = ["update"]
 }

 path "sys/leases/renew" {
   capabilities = ["update"]
 }

 path "sys/leases/revoke" {
   capabilities = ["update"]
 }

 path "sys/capabilities-self" {
   capabilities = ["update"]
 }

 path "kubernetes/creds/auto-managed-sa-and-role" {
   capabilities = ["update"]
 }
EOF

BOUNDARY_CRED_STORE_TOKEN=$(vault token create \
    -no-default-policy=true \
    -policy="boundary-controller" \
    -orphan=true \
    -period=20m \
    -renewable=true \
    -format=json | jq -r '.auth | .client_token') && echo $BOUNDARY_CRED_STORE_TOKEN

boundary authenticate password 

DEVOPS_ORG_ID=$(boundary scopes create \
    -scope-id=global \
    -name=devops \
    -description="DevOps" \
    -format json | jq -r '.item | .id') && echo $DEVOPS_ORG_ID

KUBE_PROJ_ID=$(boundary scopes create \
    -scope-id=$DEVOPS_ORG_ID \
    -name=kubernetes \
    -description="Kubernetes clusters" \
    -format json | jq -r '.item | .id') && echo $KUBE_PROJ_ID

BOUNDARY_CRED_STORE_ID=$(boundary credential-stores create vault \
    -scope-id $KUBE_PROJ_ID \
    -vault-address $VAULT_ADDR \
    -vault-token $BOUNDARY_CRED_STORE_TOKEN \
    -format json | jq -r '.item | .id') && echo $BOUNDARY_CRED_STORE_ID

BOUNDARY_CRED_LIB_ID=$(boundary credential-libraries create vault \
    -credential-store-id $BOUNDARY_CRED_STORE_ID \
    -vault-http-method "POST" \
    -vault-http-request-body "{\"kubernetes_namespace\": \"default\"}" \
    -vault-path "kubernetes/creds/auto-managed-sa-and-role" \
    -name "vault-cred-library" \
    -format json | jq -r '.item | .id') && echo $BOUNDARY_CRED_LIB_ID

KUBE_TARGET_ID=$(boundary targets create tcp \
    -name="kubernetes-api" \
    -description="Kubernetes API" \
    -default-port=64240 \
    -scope-id=$KUBE_PROJ_ID \
    -address="127.0.0.1" \
    -session-connection-limit="-1" \
    -format json | jq -r '.item | .id') && echo $KUBE_TARGET_ID

boundary targets add-credential-sources \
     -id=$KUBE_TARGET_ID \
     -application-credential-source=$BOUNDARY_CRED_LIB_ID
