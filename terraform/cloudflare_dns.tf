resource "cloudflare_record" "cname_hosting_bucket" {
  type    = "CNAME"
  zone_id = data.cloudflare_zone.zone.id
  name    = var.sub_domain
  value   = aws_s3_bucket_website_configuration.hosting_bucket.website_endpoint
  proxied = true
  ttl     = 1 # automatic
}
