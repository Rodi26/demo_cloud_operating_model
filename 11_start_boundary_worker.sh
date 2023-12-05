#!/bin/bash

# Last update : August, 2022
# Author: cetin@hashicorp.com
# Description: Start or Reset a boundary cluster in dev mode

script_name=$(basename "$0")
version="0.1.0"

echo "Running $script_name - version $version"
echo ""

HASHISTACK_DIR="$HOME/.hashistack/"
HASHISTACK_LOG_DIR="$HASHISTACK_DIR/log"
export BOUNDARY_LICENSE=file:///$HOME/license/boundary_worker.hclic

mkdir -p "$HASHISTACK_DIR/log"

# Check boundary installation.
BOUNDARY_VERSION=$(boundary version)

if [ "$?" != 0 ]; then
  # exit if boundary cli is not present
  echo "boundary cli not found. Please see https://www.boundaryproject.io/downloads to download boundary_worker."
  exit 1
fi

RESET_BOUNDARY="N"

if [ -f "$HASHISTACK_DIR/boundary_worker.pid" ]; then
    BOUNDARY_PID=$(cat "$HASHISTACK_DIR/boundary_worker.pid")
    echo "boundary seems to be running under PID $BOUNDARY_PID"
    echo "Running with this startup command:"
    echo ""
    ps |grep "$BOUNDARY_PID" |grep -o -m1 -E 'boundary_worker.+'
  echo ""
    kill -9 "$BOUNDARY_PID"
    rm "$HASHISTACK_DIR/boundary_worker.pid" "$HASHISTACK_LOG_DIR/boundary_worker.log"
  else # exit without action if answer is anything different that the accepted inputs
    echo "Already stopped"
  fi


export BOUNDARY_LOG_LEVEL=debug

#boundary server -dev -dev-root-token-id=root -dev-listen-address="0.0.0.0:8200" >"$HASHISTACK_LOG_DIR/boundary_worker.log" 2>&1 &
boundary server -config=./configuration/boundary_worker.hcl > "$HASHISTACK_LOG_DIR/boundary_worker.log" 2>&1 &
echo $! >  "$HASHISTACK_DIR/boundary_worker.pid"

sleep 5

echo "boundary started with PID:$(cat "$HASHISTACK_DIR/boundary_worker.pid")"
echo "$BOUNDARY_VERSION"
export BOUNDARY_ADDR="http://127.0.0.1:9200"
# Print connection information
echo ""
echo "Visit http://127.0.0.1:9200 to access the GUI. You can authenticate with the following information:"
#echo "user: admin"
#echo "Password: admin1234"
