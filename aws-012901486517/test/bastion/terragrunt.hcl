locals {
  common_vars      = yamldecode(file(find_in_parent_folders("common_vars.yaml")))
  environment_vars = yamldecode(file(find_in_parent_folders("environment_vars.yaml")))
  tags             = {
    stack_module = "bastion"
  }
}

include "root" {
  path = find_in_parent_folders()
}

dependency "network" {
  config_path = "../network"
}

terraform {
  source = "github.com/teokyllc/terraform-aws-ec2?ref=1.0"
}

inputs = {
  ec2_name                                = "Bastion"
  ami_most_recent                         = true
  ami_name                                = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
  ami_owner                               = "099720109477"
  subnet_id                               = dependency.network.outputs.public_subnets["public-subnet-1a"].id
  availability_zone                       = "${local.common_vars.aws_region}a"
  create_security_group                   = true
  security_group_name                     = "Bastion"
  security_group_description              = "Bastion host security group"
  security_group_vpc_id                   = dependency.network.outputs.vpc_id
  security_group_rules                    = {
    rule-1 = {
      type                     = "egress"
      description              = "internet access"
      to_port                  = 0
      from_port                = 0
      protocol                 = -1
      cidr_blocks              = ["0.0.0.0/0"]
      source_security_group_id = null
    }
    rule-2 = {
      type                     = "ingress"
      description              = "SSH access from anywhere"
      to_port                  = 22
      from_port                = 22
      protocol                 = "tcp"
      cidr_blocks              = ["0.0.0.0/0"]
      source_security_group_id = null
    }
    rule-3 = {
      type                     = "ingress"
      description              = "Wireguard VPN access server"
      to_port                  = 55555
      from_port                = 55555
      protocol                 = "udp"
      cidr_blocks              = ["0.0.0.0/0"]
      source_security_group_id = null
    }
  }
  instance_type                           = "t3.micro"
  associate_public_ip_address             = true
  disable_api_stop                        = false
  disable_api_termination                 = false
  ebs_optimized                           = false
  attach_eip                              = false
  key_name                                = "ataylor-test"
  monitoring                              = false
  user_data_replace_on_change             = false
  network_interface_delete_on_termination = true
  volume_size                             = 20
  volume_type                             = "gp3"
  volume_delete_on_termination            = true
  volume_encrypted                        = true
  user_data                               = <<EOF
#! /bin/bash
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y wget
sudo mkdir /wireguard
cd /wireguard
wget https://raw.githubusercontent.com/angristan/wireguard-install/master/wireguard-install.sh
chmod +x wireguard-install.sh
mv wireguard-install.sh wireguard.sh
EOF
}
