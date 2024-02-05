module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name                 = "test-network"
  cidr                 = "10.0.0.0/16"
  enable_dns_hostnames = true

  azs                 = ["ap-northeast-1a", "ap-northeast-1c", "ap-northeast-1d"]
  public_subnets      = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]

  enable_nat_gateway = false
}

resource "aws_db_subnet_group" "database" {
  name        = "db-subnet-group"
  description = "Database subnet group"
  subnet_ids  = module.vpc.public_subnets
}

module "services_app_mysql" {
  source = "terraform-aws-modules/rds-aurora/aws"

  name                 = "autoscale-test"
  database_name        = "autoscale"
  master_username      = "yossy"
  engine               = "aurora-mysql"
  engine_version       = "8.0.mysql_aurora.3.03.1"
  instance_class       = "db.t3.medium"
  instances            = {
    one = {
      publicly_accessible = true
    }
    two = {
      publicly_accessible = true
    }
  }
  vpc_id               = module.vpc.vpc_id
  db_subnet_group_name = aws_db_subnet_group.database.name
  security_group_rules = {
    vpc_ingress = {
      # Be carefule to open to the world
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  storage_encrypted               = true
  monitoring_interval             = 10
  deletion_protection             = false
  apply_immediately               = true
  backtrack_window                = 0
  enabled_cloudwatch_logs_exports = ["audit", "error", "general", "slowquery"]

  autoscaling_enabled      = true
  autoscaling_min_capacity = 2
  autoscaling_max_capacity = 3
  autoscaling_target_cpu   = 10
}
