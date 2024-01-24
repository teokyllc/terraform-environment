locals {
  aws_region = "us-east-2"
}


terraform {
    source = "github.com/teokyllc/terraform-aws-rds?ref=1.1"

    inputs = {
        region                          = local.aws_region
        is_db_instance                  = true
        allocated_storage               = 20
        max_allocated_storage           = 100
        rds_instace_name                = "test"
        db_name                         = "test"
        engine                          = "mysql"
        engine_version                  = "8.0"
        instance_class                  = "db.t3.micro"
        username                        = "sqladmin"
        password                        = "P@ssw*rd!"
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
        rds_subnet_tier                 = "data"
        security_group_ids              = ["sg-0c40e0d2faba017ca"]
        storage_encrypted               = false
        vpc_id                          = "vpc-0eeca0e683a8b1ca5"
        enabled_cloudwatch_logs_exports = ["audit", "error", "general", "slowquery"]
        parameters = [ 
            {
            name = "character_set_connection"
            value = "utf8"
            },
            {
            name = "character_set_server"
            value = "utf8"
            }
        ]
        tags = {
            tag = "value"
        }
    }
}