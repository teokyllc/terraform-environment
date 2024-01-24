locals {
    common_vars      = yamldecode(file(find_in_parent_folders("common_vars.yaml")))
    environment_vars = yamldecode(file(find_in_parent_folders("environment_vars.yaml")))
    tags             = {
        stack_module = "mysql"
    }
}

dependency "network" {
    config_path = "../network"
}

terraform {
    source = "github.com/teokyllc/terraform-aws-rds"
}

inputs = {
    aws_region                      = local.common_vars.aws_region
    create_db_instance              = true
    allocated_storage               = 20
    max_allocated_storage           = 100
    rds_instace_name                = "backend-mysql"
    db_name                         = "app"
    db_port                         = 3306
    db_admin_username               = "admin"
    engine                          = "mysql"
    engine_version                  = "8.0"
    instance_class                  = "db.t3.micro"
    publicly_accessible             = false
    apply_immediately               = false
    skip_final_snapshot             = true
    allow_major_version_upgrade     = false
    deletion_protection             = false
    backup_retention_period         = 7
    availability_zone               = "a"
    backup_window                   = "00:00-02:00"
    maintenance_window              = "Sun:02:00-Sun:05:00"
    multi_az                        = false
    rds_subnet_tier                 = "rds_subnet"
    storage_type                    = "gp3"
    storage_encrypted               = false
    vpc_id                          = dependency.network.outputs.vpc_id
    enabled_cloudwatch_logs_exports = ["error", "slowquery"]
    tags                            = merge(local.tags, local.common_vars.tags, local.environment_vars.tags)
    create_parameter_group          = true
    parameter_group_family          = "mysql8.0"
    create_option_group             = true
    parameters = [ 
        {
            name         = "character_set_connection"
            value        = "utf8mb4"
            apply_method = "immediate"
        },
        {
            name         = "character_set_server"
            value        = "utf8mb4"
            apply_method = "immediate"
        },
        {
            name         = "binlog_format"
            value        = "ROW"
            apply_method = "immediate"
        },
    ]
}
