terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "3.13.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.14.0"
    }
  }
}

provider "vault" {}

provider "kubernetes" {
    config_path = "~/.kube/config"
    config_context = "minikube"
}
