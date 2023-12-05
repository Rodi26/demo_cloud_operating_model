#boundary_entreprise.hcl
# disable memory from being swapped to disk
disable_mlock = true


listener "tcp" {
  address = "127.0.0.1"
  purpose = "proxy"
  tls_disable   = true
}

worker {
  name = "local-worker"
    initial_upstreams = [
    "127.0.0.1",

  ]
  tags {
    type = ["worker1", "macos"]
  }
}



kms "transit" {
 purpose            = "worker-auth"
  address            = "http://localhost:8200"
  #token              = "hvs.xxxxxxxxxxxxxxxxxxxxxxxxCb1l2U3Q0SmtLeW8"
  disable_renewal    = "false"
  key_name           = "worker"
  mount_path         = "boundary_kms/"
  namespace          = "root"
  #tls_ca_cert        = "/etc/vault/ca_cert.pem"
  #tls_client_cert    = "/etc/vault/client_cert.pem"
  #tls_client_key     = "/etc/vault/ca_cert.pem"
  #tls_server_name    = "vault"
  tls_skip_verify    = "true"
}
