# Required
variable "project_name" {
  type        = "string"
  description = "Set this, resources are given a unique name based on this"
}

variable "hashi_tags" {
  type = "map"

  default = {
    "TTL"     = ""
    "owner"   = ""
    "project" = ""
  }
}

variable "ssh_key_name" {
  description = "Name of existing AWS ssh key"
}

variable "route53_zone_id" {
  description = "Route 53 zone into which to place hostnames"
}

variable "top_level_domain" {
  description = "The top-level domain to put all Route53 records"
}

# Optional

# Images in us-east-1, us-east-2, us-west-1 and us-west-2
variable "aws_region" {
  description = "Region into which to deploy"
  default     = "us-west-2"
}

variable "consul_dc" {
  description = "Consul cluster DC name"
  default     = "dc1"
}

variable "ami_owner" {
  description = "AWS account which owns AMIs"
  default     = "self"
}

variable "ami_prefix" {
  description = "prefix of AMI images to use when building instances"
  default     = "consul-demo"
}

variable "consul_lic" {
  description = "License file content for Consul Enterprise"
  default     = ""
}

