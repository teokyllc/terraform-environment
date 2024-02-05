locals {
  common_vars      = yamldecode(file(find_in_parent_folders("common_vars.yaml")))
  environment_vars = yamldecode(file(find_in_parent_folders("environment_vars.yaml")))
  tags             = {
    stack_module = "cert-manager"
  }
}

include "root" {
  path = find_in_parent_folders()
}

dependency "eks" {
  config_path = "../eks"
}

dependency "cert-manager" {
  config_path  = "../cert-manager"
  skip_outputs = true
}

terraform {
  source = "github.com/teokyllc/terraform-kubernetes-cert-manager"
}

inputs = {
  create_self_signed_cluster_issuer = true
  self_signed_cluster_issuer_name   = "self-signed"
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
provider "kubernetes" {
  host                   = "${dependency.eks.outputs.eks_cluster_endpoint}"
  cluster_ca_certificate = base64decode("${dependency.eks.outputs.eks_certificate_authority}")
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", "${dependency.eks.outputs.eks_id}"]
    command     = "aws"
  }
}
EOF
}