# read-only
path "secret/data/myapp/*" {
    capabilities = ["read", "list"]
}
# read-only
path "/v1/kv/data/*" {
    capabilities = ["read", "list"]
}