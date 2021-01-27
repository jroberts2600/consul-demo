# Outputs

output "aws_region" {
  description = "Region into which to deploy"
  value = var.aws_region
}

output "consul_dc" {
  description = "Consul cluster DC name"
  value = var.consul_dc
}

output "consul_acl_dc" {
  description = "Consul ACL cluster name"
  value = var.consul_acl_dc
}

output "vpc_id" {
  description = "VPC ID"
  value = aws_vpc.prod.id
}

output "vpc_netblock" {
  description = "The netblock for this deployment's VPC"
  value = var.vpc_netblock
}

output "public_subnets" {
  description = "The public subnets for this deployment"
  value = aws_subnet.public.*.cidr_block
}

output "vpc_public_route_table_id" {
  description = "ID of public route table"
  value = aws_route_table.public.id
}

output "consul_lb" {
  description = "Consul Server Load Balancer FQDN"
  value = aws_route53_record.consul_lb_a_record.fqdn
}

output "consul_servers" {
  description = "Consul Server FQDNs"
  value = aws_route53_record.consul_a_records.*.fqdn
}

output "consul_servers_private_ip" {
  description = "Consul Server Private IP Addresses"
  value = aws_instance.consul.*.private_ip
}

output "webclient_lb" {
  description = "Webclient Load Balancer FQDN"
  value = aws_route53_record.webclient_lb_a_record.fqdn
}

output "webclient_servers" {
  description = "Webclient Server FQDNs"
  value = aws_route53_record.webclient_a_records.*.fqdn
}

output "listing_api_servers" {
  description = "Listing Server FQDNs"
  value = aws_route53_record.listing_a_records.*.fqdn
}

output "mongo_servers" {
  description = "Mongo Server FQDNs"
  value = aws_route53_record.mongo_a_records.*.fqdn
}

output "product_api_servers" {
  description = "Product Server FQDNs"
  value = aws_route53_record.product_a_records.*.fqdn
}
