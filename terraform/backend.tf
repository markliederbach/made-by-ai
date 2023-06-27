terraform {
  required_version = ">= 1.5.1"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.32"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 3.18"
    }
  }

  backend "remote" {
    organization = "quark"

    workspaces {
      name = "site-made-by-ai"
    }
  }
}
