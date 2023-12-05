#------------------------------------------------------------
# Create a policies from file
#------------------------------------------------------------
resource "vault_policy" "admin_policy" {
  name   = "full_admin"
  policy = file("policies/full_admin_policy.hcl")
}

#------------------------------------------------------------
# Enable userpass auth method
#------------------------------------------------------------
resource "vault_auth_backend" "userpass" {
  type = "userpass"
}

#-----------------------------------------------------------
# Create a user named 'admin' with password, 'changeme'
#-----------------------------------------------------------
resource "vault_generic_endpoint" "admin" {
  depends_on           = [vault_auth_backend.userpass]
  path                 = "auth/userpass/users/admin"
  ignore_absent_fields = true
  #namespace = "root"

  data_json = <<EOT
{
  "policies": ["full_admin"],
  "password": "changeme"
}
EOT
}

#------------------------------------------------------------
# Enable and configure kubernetes auth method
#------------------------------------------------------------
# resource "vault_auth_backend" "kubernetes" {
#     type        = "kubernetes"
# }

# resource "vault_kubernetes_auth_backend_config" "k8s-root" {
#     backend                 = vault_auth_backend.kubernetes.path
#     kubernetes_host         = "https://192.168.49.2:8443"
#     kubernetes_ca_cert      = data.kubernetes_secret.vault-server-sa.data["ca.crt"]
#     token_reviewer_jwt      = data.kubernetes_secret.vault-server-sa.data["token"]
#     issuer                  = "https://kubernetes.default.svc.cluster.local"
# }
