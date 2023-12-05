terraform {
  required_providers {
    boundary = {
      source  = "hashicorp/boundary"
      version = "1.1.3"
    }

    aws = {
      source  = "hashicorp/aws"
      version = "4.46.0"
    }

    time = {
      source  = "hashicorp/time"
      version = "0.9.1"
    }
  }
}

provider "boundary" {
  addr                            = "http://127.0.0.1:9200"
  auth_method_id                  = "ampw_IIU4BAAUzB"
  password_auth_method_login_name = "admin"
  password_auth_method_password   = "admin1234"
}

provider "aws" {}
provider "time" {}
