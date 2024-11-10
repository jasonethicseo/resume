
data "aws_kms_key" "existing_key" {
  key_id = "a5f921fe-b1e2-449d-8d3b-40eb20adc55d"  # KMS 키 ID를 여기에 입력
}

output "kms_key_arn" {
  value = data.aws_kms_key.existing_key.arn
}



resource "aws_db_subnet_group" "aurora_subnet_group" {
  name       = "aurora-subnet-group"
  subnet_ids = [aws_subnet.prv_sub_3.id, aws_subnet.prv_sub_4.id]

  tags = {
    Name = "aurora-subnet-group-primary"
  }
}

resource "aws_security_group" "aurora_sg" {
  name        = "aurora-security-group"
  description = "Security group for Aurora MySQL cluster"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "aurora-sg-primary"
  }

}

resource "aws_rds_cluster" "rds_cluster_primary" {
  cluster_identifier                  = "aurora-cluster-primary"
  engine                              = "aurora-mysql"
  engine_version                      = "8.0.mysql_aurora.3.05.2"
  availability_zones                  = ["ca-central-1a", "ca-central-1b"]
  database_name                       = "mydb"
  master_username                     = "digitalhack"
  master_password                     = var.db_master_password 
  db_subnet_group_name                = aws_db_subnet_group.aurora_subnet_group.name
  vpc_security_group_ids              = [aws_security_group.aurora_sg.id]
  storage_encrypted                   = true
  kms_key_id                          = data.aws_kms_key.existing_key.arn
  backup_retention_period             = 7
  preferred_backup_window             = "07:00-09:00"
  skip_final_snapshot                 = true
  deletion_protection                 = false

  lifecycle {
    ignore_changes = [availability_zones, engine_version, kms_key_id]
  }

}


resource "aws_rds_cluster_instance" "aurora_cluster_instances_primary" { 
  count               = 2
  identifier          = "aurora-instance-dev-todo-${count.index}"
  cluster_identifier  = aws_rds_cluster.rds_cluster_primary.id
  instance_class      = "db.r5.large"
  engine              = "aurora-mysql"
  engine_version      = "8.0.mysql_aurora.3.05.2"
  performance_insights_enabled        = true
  performance_insights_kms_key_id     = data.aws_kms_key.existing_key.arn
  performance_insights_retention_period = 7
  auto_minor_version_upgrade = false

  lifecycle {
    ignore_changes = [engine_version]
  }

}
