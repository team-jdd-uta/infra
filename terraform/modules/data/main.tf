locals {
  db_names = [for index in range(var.db_instance_count) : format("%s-%s-db-%02d", var.project_name, var.environment, index + 1)]
}

resource "aws_db_subnet_group" "mariadb" {
  name       = "${var.project_name}-${var.environment}-mariadb-subnets"
  subnet_ids = var.private_data_subnet_ids
}

resource "aws_docdb_subnet_group" "documentdb" {
  name       = "${var.project_name}-${var.environment}-documentdb-subnets"
  subnet_ids = var.private_data_subnet_ids
}

resource "aws_elasticache_subnet_group" "redis" {
  name       = "${var.project_name}-${var.environment}-redis-subnets"
  subnet_ids = var.private_data_subnet_ids
}

resource "aws_security_group" "rds" {
  name        = "${var.project_name}-${var.environment}-rds-sg"
  description = "RDS security group"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.node_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "redis" {
  name        = "${var.project_name}-${var.environment}-redis-sg"
  description = "Redis security group"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [var.node_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "documentdb" {
  name        = "${var.project_name}-${var.environment}-documentdb-sg"
  description = "DocumentDB security group"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 27017
    to_port         = 27017
    protocol        = "tcp"
    security_groups = [var.node_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "random_password" "rds" {
  count   = var.db_instance_count
  length  = 20
  special = false
}

resource "aws_secretsmanager_secret" "rds" {
  count       = var.db_instance_count
  name        = "${local.db_names[count.index]}-credentials"
  kms_key_id  = var.kms_key_arn
  description = "RDS credentials for ${local.db_names[count.index]}"
}

resource "aws_secretsmanager_secret_version" "rds" {
  count     = var.db_instance_count
  secret_id = aws_secretsmanager_secret.rds[count.index].id
  secret_string = jsonencode({
    username = "admin"
    password = random_password.rds[count.index].result
    engine   = "mariadb"
    db_name  = "app${count.index + 1}"
  })
}

resource "aws_db_instance" "mariadb" {
  count = var.db_instance_count

  identifier              = local.db_names[count.index]
  engine                  = "mariadb"
  engine_version          = "10.11"
  instance_class          = "db.t4g.medium"
  allocated_storage       = 50
  max_allocated_storage   = 200
  db_subnet_group_name    = aws_db_subnet_group.mariadb.name
  vpc_security_group_ids  = [aws_security_group.rds.id]
  username                = "admin"
  password                = random_password.rds[count.index].result
  db_name                 = "app${count.index + 1}"
  storage_encrypted       = true
  kms_key_id              = var.kms_key_arn
  backup_retention_period = 7
  multi_az                = var.environment == "prod"
  deletion_protection     = var.environment == "prod"
  skip_final_snapshot     = var.environment != "prod"
  apply_immediately       = var.environment != "prod"
}

resource "random_password" "redis_auth" {
  length  = 32
  special = false
}

resource "aws_secretsmanager_secret" "redis" {
  name       = "${var.project_name}-${var.environment}-redis-auth"
  kms_key_id = var.kms_key_arn
}

resource "aws_secretsmanager_secret_version" "redis" {
  secret_id = aws_secretsmanager_secret.redis.id
  secret_string = jsonencode({
    auth_token = random_password.redis_auth.result
  })
}

resource "aws_elasticache_replication_group" "redis" {
  replication_group_id       = "${var.project_name}-${var.environment}-redis"
  description                = "${var.project_name}-${var.environment} redis"
  engine                     = "redis"
  engine_version             = "7.1"
  node_type                  = var.redis_node_type
  port                       = 6379
  parameter_group_name       = "default.redis7.cluster.on"
  num_node_groups            = 2
  replicas_per_node_group    = 1
  subnet_group_name          = aws_elasticache_subnet_group.redis.name
  security_group_ids         = [aws_security_group.redis.id]
  automatic_failover_enabled = true
  multi_az_enabled           = true
  at_rest_encryption_enabled = true
  transit_encryption_enabled = true
  auth_token                 = random_password.redis_auth.result
}

resource "random_password" "documentdb" {
  length  = 20
  special = false
}

resource "aws_secretsmanager_secret" "documentdb" {
  name       = "${var.project_name}-${var.environment}-documentdb-credentials"
  kms_key_id = var.kms_key_arn
}

resource "aws_secretsmanager_secret_version" "documentdb" {
  secret_id = aws_secretsmanager_secret.documentdb.id
  secret_string = jsonencode({
    username = "docdbadmin"
    password = random_password.documentdb.result
  })
}

resource "aws_docdb_cluster" "this" {
  cluster_identifier      = "${var.project_name}-${var.environment}-documentdb"
  engine                  = "docdb"
  master_username         = "docdbadmin"
  master_password         = random_password.documentdb.result
  db_subnet_group_name    = aws_docdb_subnet_group.documentdb.name
  vpc_security_group_ids  = [aws_security_group.documentdb.id]
  storage_encrypted       = true
  kms_key_id              = var.kms_key_arn
  backup_retention_period = 7
  skip_final_snapshot     = var.environment != "prod"
  deletion_protection     = var.environment == "prod"
  apply_immediately       = var.environment != "prod"
}

resource "aws_docdb_cluster_instance" "this" {
  count              = 2
  identifier         = "${var.project_name}-${var.environment}-documentdb-${count.index + 1}"
  cluster_identifier = aws_docdb_cluster.this.id
  instance_class     = var.documentdb_instance_class
}
