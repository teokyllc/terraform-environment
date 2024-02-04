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

terraform {
  source = "github.com/teokyllc/terraform-kubernetes-istio?ref=1.0"
}

inputs = {
  aws_region               = local.common_vars.aws_region
  enable_cert_manager      = true
  cert_manager_version     = "v1.12.3"
  cert_manager_namespace   = "cert-manager"
  cert_manager_role_name   = "${dependency.eks.outputs.eks_id}-cert-manager-irsa"
  cert_manager_policy_name = "${dependency.eks.outputs.eks_id}-cert-manager-irsa-policy"
  eks_iodc_hash            = dependency.eks.outputs.eks_oidc_hash
  route_53_hosted_zones    = [local.environment_vars.domain_name]
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