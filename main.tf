terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.34.0"
    }
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "~> 2.3.2"
    }
  }
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "hudl"
    workspaces {
      name = "wyscout-magicbox-prod"
    }
  }
  required_version = ">= 1.3.2"
}
