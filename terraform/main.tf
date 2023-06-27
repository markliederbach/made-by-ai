provider "aws" {
  region              = "us-west-2"
  allowed_account_ids = ["003521492892"]
  default_tags {
    tags = var.common_tags
  }
}

provider "cloudflare" {
}
