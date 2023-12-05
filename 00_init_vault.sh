#!/bin/bash

# Last update : August, 2022
# Author: cetin@hashicorp.com
# Description: Start or Reset a Vault cluster in dev mode

script_name=$(basename "$0")
version="0.1.0"

echo "Running $script_name - version $version"
echo ""

HASHISTACK_DIR="$HOME/.hashistack/"
HASHISTACK_LOG_DIR="$HASHISTACK_DIR/log"

mkdir -p "$HASHISTACK_DIR/log"

# Check vault installation.
VAULT_VERSION=$(vault version)

if [ "$?" != 0 ]; then
  # exit if vault cli is not present
  echo "vault cli not found. Please see https://www.vaultproject.io/downloads to download Vault."
  exit 1
fi




vault server -dev -dev-root-token-id=root -dev-listen-address="0.0.0.0:8200" >"$HASHISTACK_LOG_DIR/vault.log" 2>&1 &

echo $! >  "$HASHISTACK_DIR/vault.pid"

sleep 5

echo "Vault started with PID:$(cat "$HASHISTACK_DIR/vault.pid")"
echo "$VAULT_VERSION"

# Print connection information
echo ""
echo "Visit http://127.0.0.1:8200/ui to access the GUI. You can authenticate with the following information:"
echo "auth method: Token"
echo "Token: root"
