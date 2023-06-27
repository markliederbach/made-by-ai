
# IP Ranges of Cloudflare edge nodes
data "cloudflare_ip_ranges" "cloudflare" {}

locals {
  domain = "${var.sub_domain}.${var.base_domain}"
}
