# Required
variable "project_name" {
  type        = string
  description = "Project Name - used to set unique resource names"
}

variable "hashi_tags" {
  type = map(string)
  description = "Tags to apply to resources" 

  default = {
    "TTL"     = "24"
    "owner"   = "HashiCorpDemo"
    "project" = "ConsulDemo001"
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

variable "aws_region" {
  description = "Region into which to deploy"
  default     = "us-west-2"
}

variable "consul_lic" {
  description = "License file content for Consul Enterprise"
  default     = ""
}

variable "consul_dc" {
  description = "Consul cluster DC name"
  default     = "dc1"
}

variable "consul_acl_dc" {
  description = "Consul ACL cluster name"
  default     = "dc1"
}

variable "ami_owner" {
  description = "AWS account which owns AMIs"
  default     = "753646501470" # hc-sc-demos-2018
}

variable "ami_prefix" {
  description = "prefix of AMI images to use when building instances"
  default     = "consul-demo"
}

variable "server_machine_type" {
  description = "The machine type (size) to deploy"
  default     = "t2.micro"
}

variable "consul_servers_count" {
  description = "How many Consul servers to create in each region"
  default     = "3"
}

variable "client_machine_type" {
  description = "The machine type (size) to deploy"
  default     = "t2.micro"
}

variable "client_db_count" {
  description = "The number of client machines to create in each region"
  default     = "1"
}

variable "client_product_count" {
  description = "The number of product machines to create in each region"
  default     = "2"
}

variable "client_listing_count" {
  description = "The number of listing machines to create in each region"
  default     = "2"
}

variable "client_webclient_count" {
  description = "The number of webclients to create in each region"
  default     = "2"
}

variable "vpc_netblock" {
  description = "The netblock for this deployment's VPC"
  default     = "10.0.0.0/16"
}

variable "internal_netblock" {
  description = "Global netblock"
  default     = "10.0.0.0/8"
}
