resource "aws_security_group" "rds_sg" {
  name        = "${var.environment}-rds-sg"
  description = "Allow PostgreSQL access"
  vpc_id      = var.vpc_id

  ingress {
    description = "PostgreSQL"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-rds-sg"
  }
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "${var.environment}-rds-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "${var.environment}-rds-subnet-group"
  }
}


# # DB Subnet Group
# resource "aws_db_subnet_group" "rds_subnet_group" {
#   name       = "${var.environment}-rds-subnet-group"
#   subnet_ids = aws_subnet.db[*].id

#   tags = {
#     Name = "${var.environment}-rds-subnet-group"
#   }
# }

# RDS PostgreSQL Instance
resource "aws_db_instance" "postgres" {
  identifier              = "${var.environment}-postgres-db"
  allocated_storage       = 20
  storage_type            = var.db_storage_type
  engine                  =  var.db_engine
  engine_version          = var.engine_version
  instance_class          = var.instance_class
  username                = var.db_user
  password                = var.db_password
  db_subnet_group_name    = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  multi_az                = false
  publicly_accessible     = false
  skip_final_snapshot     = true
  backup_retention_period = 7

  tags = {
    Name = "${var.environment}-postgres-db"
  }
}
