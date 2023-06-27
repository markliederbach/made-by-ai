variable "common_tags" {
  type        = object({})
  description = "Key/Value tags to attach to AWS resources"
}

variable "sub_domain" {
  type    = string
  default = "ai"
}

variable "base_domain" {
  type    = string
  default = "liederbach.dev"
}
