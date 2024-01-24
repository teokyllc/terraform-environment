locals {
    common_vars      = yamldecode(file(find_in_parent_folders("common_vars.yaml")))
    environment_vars = yamldecode(file(find_in_parent_folders("environment_vars.yaml")))
    tags             = {
        stack_module = "network"
    }
}

include "root" {
    path = find_in_parent_folders()
}

terraform {
    source = "github.com/teokyllc/terraform-aws-vpc?ref=1.0"
}

inputs = {
    region                  = local.common_vars.aws_region
    vpc_name                = "${local.environment_vars.environment}-vpc"
    cidr_block              = "10.0.0.0/16"
    instance_tenancy        = "default"
    enable_dns_support      = true
    enable_dns_hostnames    = true
    subnets                 = {
        public = {
            public-subnet-1a    = {
                availability_zone        = "${local.common_vars.aws_region}a"
                cidr_block               = "10.0.0.0/24"
                map_public_ip_on_launch  = true
                tags = {
                    tier                     = "public"
                    rds_subnet               = "false"
                    "kubernetes.io/role/elb" = "1"
                }
            }
            public-subnet-1b    = {
                availability_zone        = "${local.common_vars.aws_region}b"
                cidr_block               = "10.0.1.0/24"
                map_public_ip_on_launch  = "true"
                tags = {
                    tier                     = "public"
                    rds_subnet               = "false"
                    "kubernetes.io/role/elb" = "1"
                }
            }
        }
        private = {
            private-subnet-1a   = {
                availability_zone                 = "${local.common_vars.aws_region}a"
                cidr_block                        = "10.0.2.0/24"
                map_public_ip_on_launch           = "false"
                tags = {
                    tier                              = "private"
                    rds_subnet                        = "true"
                    "kubernetes.io/role/internal-elb" = "0"
                }
            }
            private-subnet-1b   = {
                availability_zone                 = "${local.common_vars.aws_region}b"
                cidr_block                        = "10.0.3.0/24"
                map_public_ip_on_launch           = "false"
                tags = {
                    tier                              = "private"
                    rds_subnet                        = "true"
                    "kubernetes.io/role/internal-elb" = "0"
                }
            }
        }
    }
    route_tables            = ["public", "private"]
    enable_internet_gateway = true
    enable_nat_gateway      = false
    nat_gw_subnet           = "public-subnet-1a"
    tags                    = merge(local.tags, local.common_vars.tags, local.environment_vars.tags)

    remove_nacl_allow_all_rule = false
    nacl_rules                 = {}
}