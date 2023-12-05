#!/bin/bash

# Last update : July, 2022
# Author: cetin@hashicorp.com
# Description: Start or Reset a 1-node minikube cluster
# source : https://github.com/kral2/vault-kubernetes
# updated by me ;)

script_name=$(basename "$0")
version="0.1.0"

echo "Running $script_name - version $version"
echo ""

# Configuration parameters - adjust it to your needs
K8S_VERSION="latest" # End of Life for 1.24 is 2023-07-28
K8S_NODE_CPU="4" # minikube default
K8S_NODE_MEM="10g" # reduced from minikube default 7g allocation

# Check minikube installation.


MINIKUBE_VERSION=$(minikube version --short)
if [ "$?" != 0 ]; then
  # exit if minikube cli is not present
  echo "minikube installation not found. Please see https://minikube.sigs.k8s.io/docs/start/" for installation steps.
  MINIKUBE_VERSION=latest
  exit 1
else
  # Capture minikube version and host status, and if a valid minikube cluster already exists
  MINIKUBE_VERSION=$(minikube version --short)
  MINIKUBE_STATUS=$(minikube status -o json | jq -r .Host)
  MINIKUBE_PROFILE=$(minikube profile list -o json |jq -r '.valid[0].Name')
  echo "minikube version $MINIKUBE_VERSION found."
fi
echo "Minikube profile:" $MINIKUBE_PROFILE
RESET_MINIKUBE="Y"

# Cluster creation/reset logic
if # no valid profile exist, then ask if you would like to create one
  [ "$MINIKUBE_PROFILE" == null ]; then
  read -rp "No valid minikube profile was found. Do you want to start a new cluster? (Y/n): " RESET_MINIKUBE
  if # 'Y', 'y' and hit enter are the only valid inputs to proceed with cluster creation
    [ "$RESET_MINIKUBE" == "" ] || [ "$RESET_MINIKUBE" == "Y" ] || [ "$RESET_MINIKUBE" == "y" ]; then
    minikube start --driver=docker --cpus "$K8S_NODE_CPU" --memory "$K8S_NODE_MEM" --kubernetes-version "$K8S_VERSION"
  else # exit without action if answer is anything different that the accepted inputs
    echo "No action. Exiting"
    minikube start --driver=docker --cpus "$K8S_NODE_CPU" --memory "$K8S_NODE_MEM" --kubernetes-version "$K8S_VERSION"
    exit 1
  fi
else # a profile already exist, ask should it be reset or not
  echo "Host status: $MINIKUBE_STATUS"
  read -rp "Do you want to reset your minikube cluster with default configuration? (Y/n): " RESET_MINIKUBE
fi

if # 'Y', 'y' and hit enter are the only valid inputs to proceed with cluster creation
  [ "$RESET_MINIKUBE" == "" ] || [ "$RESET_MINIKUBE" == "Y" ] || [ "$RESET_MINIKUBE" == "y" ]; then
    if # host running, stop it before delete/recreate
    [ "$MINIKUBE_STATUS" == "Running"  ]; then
    minikube stop && minikube delete && minikube start --driver=docker --cpus "$K8S_NODE_CPU" --memory "$K8S_NODE_MEM" --kubernetes-version "$K8S_VERSION"
    elif # host stopped, delete and recreate
    [ "$MINIKUBE_STATUS" == "Stopped" || [ "$RESET_MINIKUBE" == "Y" ] || [ "$RESET_MINIKUBE" == "y" ]; then
      minikube delete && minikube start --driver=docker --cpus "$K8S_NODE_CPU" --memory "$K8S_NODE_MEM" --kubernetes-version "$K8S_VERSION"
    fi
    else # exit without action 
  echo "No action. Exiting"
  minikube start --driver=docker --cpus "$K8S_NODE_CPU" --memory "$K8S_NODE_MEM" --kubernetes-version "$K8S_VERSION"
  exit 1
  fi
else
  exit 1
fi

# Print connection information

echo ""
echo "Run the command below in another terminal to open the Kubernetes dashboard in your default browser:"
echo "   minikube dashboard"
