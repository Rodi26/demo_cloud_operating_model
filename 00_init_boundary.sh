#!/bin/bash

# Last update : August, 2022
# Author: cetin@hashicorp.com
# Description: Start or Reset a boundary cluster in server mode
./11_start_postgre..sh

script_name=$(basename "$0")
version="0.1.0"

echo "Running $script_name - version $version"
echo ""

HASHISTACK_DIR="$HOME/.hashistack/"
HASHISTACK_LOG_DIR="$HASHISTACK_DIR/log"

mkdir -p "$HASHISTACK_DIR/log"

# Check boundary installation.
BOUNDARY_VERSION=$(boundary version)

if [ "$?" != 0 ]; then
  # exit if boundary cli is not present
  echo "boundary cli not found. Please see https://www.boundaryproject.io/downloads to download boundary."
  exit 1
fi

RESET_BOUNDARY="N"

if [ -f "$HASHISTACK_DIR/boundary.pid" ]; then
    BOUNDARY_PID=$(cat "$HASHISTACK_DIR/boundary.pid")
    echo "boundary seems to be running under PID $BOUNDARY_PID"
    echo "Running with this startup command:"
    echo ""
    ps |grep "$BOUNDARY_PID" |grep -o -m1 -E 'boundary.+'
  echo ""
    kill -9 "$BOUNDARY_PID"
    rm "$HASHISTACK_DIR/boundary.pid" "$HASHISTACK_LOG_DIR/boundary.log"
  else # exit without action if answer is anything different that the accepted inputs
    echo "Already stopped"
  fi


export BOUNDARY_LOG_LEVEL=debug

boundary database init \
   -config ./configuration/boundary_enterprise.hcl
_='
boundary database init \
   -skip-auth-method-creation \
   -skip-host-resources-creation \
   -skip-scopes-creation \   
   -skip-target-creation \
   -config ./configuration/boundary_enterprise.hcl
'

sleep 5

