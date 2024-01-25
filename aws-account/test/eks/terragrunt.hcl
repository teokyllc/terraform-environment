locals {
    common_vars      = yamldecode(file(find_in_parent_folders("common_vars.yaml")))
    environment_vars = yamldecode(file(find_in_parent_folders("environment_vars.yaml")))
    tags             = {
        stack_module = "kubernetes"
    }
}

dependency "network" {
    config_path = "../network"
}

terraform {
    source = "github.com/teokyllc/terraform-aws-eks"
}

inputs = {
    eks_version                                 = "1.28"
    cluster_name                                = "example"
    vpc_id                                      = dependency.network.outputs.vpc_id
    eks_subnet_tier                             = "private"
    eks_cluster_role_name                       = "eks-cluster-example"
    eks_worker_role_name                        = "eks-node-group-example"
    enable_private_access                       = true
    enable_public_access                        = false
    enable_eks_control_plane_logging            = false
    eks_control_plane_logging_retention_in_days = 7
    cluster_log_types                           = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
    tags                                        = merge(local.tags, local.common_vars.tags, local.environment_vars.tags)
    eks_node_groups = {
        default = {
            role_name                         = "${local.environment_vars.environment}-eks-default-node-group-role"
            launch_template_name              = "${local.environment_vars.environment}-eks-node-group-launch-template"
            launch_template_instance_type     = "t3.medium"
            launch_template_key_name          = "ataylor-test"
            launch_template_block_device_name = "/dev/xvda"
            launch_template_version           = 1
            volume_size                       = 256
            node_pool_desired_size            = 2
            node_pool_min_size                = 2
            node_pool_max_size                = 2
            labels                            = {
                "app-role" = "default"
            }
        }
    }
}