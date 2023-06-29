resource "cloudflare_page_rule" "all_pages" {
  zone_id  = data.cloudflare_zone.zone.id
  target   = "${local.domain}/*"
  priority = 1
  status   = "active"

  actions {
    cache_level = "cache_everything"
  }
}
