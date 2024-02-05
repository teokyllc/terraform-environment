locals {
  common_vars      = yamldecode(file(find_in_parent_folders("common_vars.yaml")))
  environment_vars = yamldecode(file(find_in_parent_folders("environment_vars.yaml")))
  tags             = {
    stack_module = "kibana"
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

dependency "istio" {
  config_path  = "../istio"
}

terraform {
  source = "github.com/teokyllc/terraform-kubernetes-elasticsearch"
}

inputs = {
  deploy_kibana                         = true
  kibana_name                           = "kb"
  kibana_namespace                      = local.environment_vars.elk_namespace
  kibana_version                        = local.environment_vars.elk_apps_version
  elasticsearch_name                    = "es"
  elasticsearch_namespace               = local.environment_vars.elk_namespace
  elasticsearch_disable_self_signed_tls = local.environment_vars.elasticsearch_disable_self_signed_tls
  enable_istio                          = true
  istio_ingress_gateway_name            = dependency.istio.outputs.ingress_gateway_istio_label
  istio_dns_names                       = ["elasticsearch.${local.environment_vars.domain_name}", "kibana.${local.environment_vars.domain_name}", "logstash.${local.environment_vars.domain_name}"]
  istio_tls_secret_name                 = "istio-ingressgateway-certificate"
  elasticsearch_dns_name                = "elasticsearch.${local.environment_vars.domain_name}"
  kibana_dns_name                       = "kibana.${local.environment_vars.elk_namespace}"
  logstash_dns_name                     = "logstash.${local.environment_vars.elk_namespace}"
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