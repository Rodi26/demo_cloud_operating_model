#!/bin/bash

function update_profile() {
  rcFile="$HOME/.zshrc"

  prop="$1"   # export property to insert
  val="$2"          # the desired value

  if grep -q "^export $prop=" "$rcFile"; then
    sed -i.backup "s|^export $prop=.*|export $prop=$val|" "$rcFile" &&
    echo "[updated] export $prop=$val"
  else
    echo -e "export $prop=$val" >> "$rcFile"
    echo "[inserted] export $prop=$val"
  fi
} 


if [ ! -d "$HOME/pgdata" ]; then
  echo "$HOME/pgdata does not exist."
  mkdir "$HOME\pgdata"
fi

if [ ! -d "$HOME/boundary" ]; then
  echo "$HOME/boundary does not exist."
  mkdir "$HOME/boundary"
fi

if [ ! -d "$HOME/boundary_logs" ]; then
  echo "$HOME/boundary_logs does not exist."
  mkdir "$HOME/boundary_logs"
fi

if [ ! -d "$HOME/vault" ]; then
  echo "$HOME/vault does not exist."
  mkdir "$HOME/vault"
fi
echo "Please copy your license file to $HOME/license"
if [ ! -d "$HOME/license" ]; then
  echo "$HOME/license does not exist."
  echo "Please copy your license file to $HOME/license"
  mkdir "$HOME/license"
fi

brew tap hashicorp/tap
brew update
brew upgrade

brew install hashicorp/tap/boundary-enterprise
brew install hashicorp/tap/vault-enterprise
#brew install hashicorp/tap/consul-enterprise


update_profile "BOUNDARY_LICENSE" "file:///$HOME/license/boundary.hclic"
update_profile "VAULT_LICENSE_PATH" "$HOME/license/vault.hclic" 
update_profile "CONSUL_LICENSE_PATH" "$HOME/license/consul.hclic"

cat ./configuration/boundary_enterprise.tmpl | sed -e "s|my_path|$HOME|g" > ./configuration/boundary_enterprise.hcl
cat ./configuration/vault.tmpl | sed -e "s|my_path|$HOME|g" > ./configuration/vault.hcl
source $HOME/.zshrc