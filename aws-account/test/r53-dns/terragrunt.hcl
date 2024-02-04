locals {
  common_vars      = yamldecode(file(find_in_parent_folders("common_vars.yaml")))
  environment_vars = yamldecode(file(find_in_parent_folders("environment_vars.yaml")))
  tags             = {
    stack_module = "r53-domain"
  }
}

include "root" {
  path = find_in_parent_folders()
}

dependency "network" {
  config_path = "../network"
}

terraform {
  source = "github.com/teokyllc/terraform-aws-route53"
}

inputs = {
  create_dns_zone    = true
  domain_name        = local.environment_vars.domain_name
  domain_comment     = "An example domain."
  enable_private_dns = true
  vpc_id             = dependency.network.outputs.vpc_id
  force_destroy      = true
  tags               = merge(local.tags, local.common_vars.tags, local.environment_vars.tags)
}