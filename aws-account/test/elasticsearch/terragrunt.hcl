locals {
  common_vars      = yamldecode(file(find_in_parent_folders("common_vars.yaml")))
  environment_vars = yamldecode(file(find_in_parent_folders("environment_vars.yaml")))
  tags             = {
    stack_module = "elasticsearch"
  }
}

include "root" {
  path = find_in_parent_folders()
}

dependency "eks" {
  config_path = "../eks"
}

dependency "elastic-operator" {
  config_path  = "../elastic-operator"
  skip_outputs = true
}

terraform {
  source = "github.com/teokyllc/terraform-kubernetes-elasticsearch"
}

inputs = {
  deploy_elasticsearch                      = true
  create_elasticsearch_namespace            = true
  elasticsearch_namespace                   = local.common_vars.elk_namespace
  elasticsearch_name                        = "es"
  elasticsearch_version                     = local.common_vars.elk_apps_version
  elasticsearch_disable_self_signed_tls     = local.common_vars.elasticsearch_disable_self_signed_tls
  elasticsearch_master_node_set_count       = "1"
  elasticsearch_data_node_set_count         = "1"
  elasticsearch_master_role_disk_size_in_gb = "10"
  elasticsearch_data_role_disk_size_in_gb   = "20"
  elasticsearch_storage_class_name          = "gp2"
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