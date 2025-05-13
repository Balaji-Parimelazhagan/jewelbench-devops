resource "aws_security_group" "redis_sg" {
  name   = "${var.environment}-redis-${var.project_name}-sg"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"] 
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-redis-${var.project_name}-sg"
  }
}



resource "aws_elasticache_subnet_group" "redis" {
  name       = "${var.environment}-redis-${var.project_name}-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "${var.environment}-redis-${var.project_name}-subnet-group"
  }
}

resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "${var.environment}-redis-${var.project_name}"
  engine               = "redis"
  node_type            = var.node_type
  num_cache_nodes      = var.num_cache_nodes
  parameter_group_name = "default.redis7"
  port                 = 6379
  subnet_group_name    = aws_elasticache_subnet_group.redis.name
  security_group_ids   = [aws_security_group.redis_sg.id]

  tags = {
    Name = "${var.environment}-redis-${var.project_name}"
  }
}
