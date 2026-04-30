locals {
  db_names         = [for index in range(var.db_instance_count) : format("%s-%s-db-%02d", var.project_name, var.environment, index + 1)]
  msk_name_suffix  = endswith(var.msk_kafka_version, ".kraft") ? "-kraft" : ""
  msk_cluster_name = "${var.project_name}-${var.environment}-msk${local.msk_name_suffix}"
  msk_config_name  = "${var.project_name}-${var.environment}-msk-config${local.msk_name_suffix}-${replace(var.msk_kafka_version, ".", "-")}"
}

resource "aws_db_subnet_group" "mariadb" {
  name       = "${var.project_name}-${var.environment}-mariadb-subnets"
  subnet_ids = var.private_data_subnet_ids
}

resource "aws_docdb_subnet_group" "documentdb" {
  name       = "${var.project_name}-${var.environment}-documentdb-subnets"
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

resource "aws_security_group" "msk" {
  name        = "${var.project_name}-${var.environment}-msk-sg"
  description = "MSK security group"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 9098
    to_port         = 9098
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

resource "aws_security_group" "msk_connect" {
  name        = "${var.project_name}-${var.environment}-msk-connect-sg"
  description = "MSK Connect security group"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "rds_from_msk_connect" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = aws_security_group.rds.id
  source_security_group_id = aws_security_group.msk_connect.id
}

resource "aws_security_group_rule" "msk_from_msk_connect" {
  type                     = "ingress"
  from_port                = 9098
  to_port                  = 9098
  protocol                 = "tcp"
  security_group_id        = aws_security_group.msk.id
  source_security_group_id = aws_security_group.msk_connect.id
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

resource "aws_msk_configuration" "this" {
  kafka_versions    = [var.msk_kafka_version]
  name              = local.msk_config_name
  server_properties = <<-EOT
    auto.create.topics.enable=false
    default.replication.factor=2
    min.insync.replicas=2
    num.partitions=3
  EOT

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_msk_cluster" "this" {
  cluster_name           = local.msk_cluster_name
  kafka_version          = var.msk_kafka_version
  number_of_broker_nodes = var.msk_number_of_broker_nodes

  broker_node_group_info {
    instance_type   = var.msk_broker_instance_type
    client_subnets  = var.private_data_subnet_ids
    security_groups = [aws_security_group.msk.id]

    storage_info {
      ebs_storage_info {
        volume_size = 100
      }
    }
  }

  configuration_info {
    arn      = aws_msk_configuration.this.arn
    revision = aws_msk_configuration.this.latest_revision
  }

  encryption_info {
    encryption_at_rest_kms_key_arn = var.kms_key_arn

    encryption_in_transit {
      client_broker = "TLS"
      in_cluster    = true
    }
  }

  client_authentication {
    sasl {
      iam = true
    }
  }

  logging_info {
    broker_logs {
      cloudwatch_logs {
        enabled   = true
        log_group = aws_cloudwatch_log_group.msk.name
      }
    }
  }
}

resource "aws_cloudwatch_log_group" "msk_connect" {
  count             = var.enable_debezium_connector ? 1 : 0
  name              = "/aws/msk-connect/${var.project_name}-${var.environment}/debezium-source"
  retention_in_days = 14
}

resource "aws_iam_role" "msk_connect" {
  count = var.enable_debezium_connector ? 1 : 0
  name  = "${var.project_name}-${var.environment}-msk-connect-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "kafkaconnect.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "msk_connect" {
  count = var.enable_debezium_connector ? 1 : 0
  name  = "${var.project_name}-${var.environment}-msk-connect-policy"
  role  = aws_iam_role.msk_connect[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "kafka-cluster:Connect",
          "kafka-cluster:DescribeCluster",
          "kafka-cluster:DescribeClusterDynamicConfiguration",
          "kafka-cluster:DescribeTopic",
          "kafka-cluster:CreateTopic",
          "kafka-cluster:WriteData",
          "kafka-cluster:ReadData",
          "kafka-cluster:AlterGroup",
          "kafka-cluster:DescribeGroup"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DeleteNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeVpcs"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Resource = aws_cloudwatch_log_group.msk_connect[0].arn
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          var.debezium_plugin_bucket_arn,
          "${var.debezium_plugin_bucket_arn}/*"
        ]
      }
    ]
  })
}

resource "aws_mskconnect_custom_plugin" "debezium" {
  count        = var.enable_debezium_connector ? 1 : 0
  name         = "${var.project_name}-${var.environment}-debezium-plugin"
  content_type = "ZIP"

  location {
    s3 {
      bucket_arn = var.debezium_plugin_bucket_arn
      file_key   = var.debezium_plugin_file_key
    }
  }
}

resource "aws_mskconnect_connector" "debezium_source" {
  count                = var.enable_debezium_connector ? 1 : 0
  name                 = "${var.project_name}-${var.environment}-debezium-source"
  kafkaconnect_version = var.msk_connect_kafkaconnect_version

  capacity {
    provisioned_capacity {
      mcu_count    = var.debezium_mcu_count
      worker_count = var.debezium_worker_count
    }
  }

  connector_configuration = {
    "connector.class"                                 = "io.debezium.connector.mysql.MySqlConnector"
    "database.hostname"                               = aws_db_instance.mariadb[0].address
    "database.port"                                   = "3306"
    "database.user"                                   = "admin"
    "database.password"                               = random_password.rds[0].result
    "database.server.id"                              = var.debezium_database_server_id
    "database.server.name"                            = "${var.project_name}-${var.environment}-mariadb"
    "database.include.list"                           = var.debezium_database_include_list
    "topic.prefix"                                    = var.debezium_topic_prefix
    "include.schema.changes"                          = "false"
    "tasks.max"                                       = tostring(var.debezium_tasks_max)
    "schema.history.internal.kafka.bootstrap.servers" = aws_msk_cluster.this.bootstrap_brokers_sasl_iam
    "schema.history.internal.kafka.topic"             = "${var.debezium_topic_prefix}.schema-history"
  }

  kafka_cluster {
    apache_kafka_cluster {
      bootstrap_servers = aws_msk_cluster.this.bootstrap_brokers_sasl_iam

      vpc {
        security_groups = [aws_security_group.msk_connect.id]
        subnets         = var.private_data_subnet_ids
      }
    }
  }

  kafka_cluster_client_authentication {
    authentication_type = "IAM"
  }

  kafka_cluster_encryption_in_transit {
    encryption_type = "TLS"
  }

  plugin {
    custom_plugin {
      arn      = aws_mskconnect_custom_plugin.debezium[0].arn
      revision = aws_mskconnect_custom_plugin.debezium[0].latest_revision
    }
  }

  log_delivery {
    worker_log_delivery {
      cloudwatch_logs {
        enabled   = true
        log_group = aws_cloudwatch_log_group.msk_connect[0].name
      }
    }
  }

  service_execution_role_arn = aws_iam_role.msk_connect[0].arn
}

resource "aws_cloudwatch_log_group" "msk" {
  name              = "/aws/msk/${var.project_name}-${var.environment}"
  retention_in_days = 14
}

resource "random_password" "documentdb" {
  length  = 20
  special = false
}

resource "aws_secretsmanager_secret" "documentdb" {
  name = "${var.project_name}-${var.environment}-documentdb-credentials"
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
