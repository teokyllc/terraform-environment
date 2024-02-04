locals {
  common_vars      = yamldecode(file(find_in_parent_folders("common_vars.yaml")))
  environment_vars = yamldecode(file(find_in_parent_folders("environment_vars.yaml")))
  tags             = {
    stack_module = "istio"
  }
}

include "root" {
  path = find_in_parent_folders()
}

dependency "eks" {
  config_path = "../eks"
}

terraform {
  source = "github.com/teokyllc/terraform-kubernetes-istio?ref=1.0"
}

inputs = {
  istio_namespace                      = "istio-system"
  istio_version                        = "1.19.1"
  istiod_replica_count                 = "1"
  ingress_gateway_replica_count        = "1"
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
provider "helm" {
  kubernetes {
    host                   = "${dependency.eks.outputs.eks_cluster_endpoint}"
    cluster_ca_certificate = base64decode("${dependency.eks.outputs.eks_certificate_authority}")
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", "${dependency.eks.outputs.eks_id}"]
      command     = "aws"
    }
  }
}
EOF
}