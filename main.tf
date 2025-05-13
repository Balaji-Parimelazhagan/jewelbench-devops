
module "vpc" {
  source               = "./common/vpc"
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  public_subnets_cidr  = var.public_subnets_cidr
  private_subnets_cidr = var.private_subnets_cidr
  db_subnets_cidr      = var.db_subnets_cidr
  availability_zones   = var.availability_zones
  create_eip           = var.create_eip
}

module "s3" {
  source                      = "./frontend/s3"
  environment                 = var.environment
  bucket_name                 = "${var.environment}-ui-${var.bucket_name}"
  acl                         = var.acl
  enable_versioning           = true
  cloudfront_distribution_arn = module.cloudfront.cloudfront_distribution_arn
  object_ownership            = var.object_ownership
}

module "cloudfront" {
  source                               = "./frontend/cloudfront"
  frontend_bucket_name                 = "${var.environment}-ui-${var.frontend_bucket_name}"
  frontend_bucket_regional_domain_name = module.s3.frontend_bucket_regional_domain_name
  s3_arn                               = module.s3.frontend_s3_arn
  s3_name                              = "${var.environment}-ui-${var.bucket_name}"
}

module "rds" {
  source          = "./db/rds"
  environment     = var.environment
  project_name    = var.project_name
  db_user         = var.db_user
  db_password     = var.db_password
  db_name         = var.db_name
  db_storage_type = var.db_storage_type
  db_engine       = var.db_engine
  engine_version  = var.engine_version
  instance_class  = var.instance_class
  allowed_cidrs   = var.allowed_cidrs
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids
}


module "redis" {
  source            = "./db/redis"
  name              = var.redis_name
  node_type         = var.redis_node_type
  num_cache_nodes   = var.redis_num_nodes
  subnet_ids        = module.vpc.private_subnet_ids
  environment       = var.environment
  project_name      = var.project_name
  vpc_id            = module.vpc.vpc_id
}


module "ecr-backend-app" {
  source              = "./modules/ecr"
  repository_name     = "${var.environment}-backend-${var.project_name}"
  image_tag_mutability = "IMMUTABLE"
  scan_on_push        = true
  force_delete        = true
  tags                = var.AWS_TAGS
}


# module "ecr-base-model" {
#   source              = "./modules/ecr"
#   repository_name     = "base-model"
#   image_tag_mutability = "IMMUTABLE"
#   scan_on_push        = true
#   force_delete        = true
#   tags                = var.AWS_TAGS
# }


# module "ecr-hd-model" {
#   source              = "./modules/ecr"
#   repository_name     = "hd-model"
#   image_tag_mutability = "IMMUTABLE"
#   scan_on_push        = true
#   force_delete        = true
#   tags                = var.AWS_TAGS
# }


# module "ecr-text-to-3d-model" {
#   source              = "./modules/ecr"
#   repository_name     = "text-to-model"
#   image_tag_mutability = "IMMUTABLE"
#   scan_on_push        = true
#   force_delete        = true
#   tags                = var.AWS_TAGS
# }


module "ai_model_fifo_queues" {
  source                      = "./modules/sqs"
  sqs_name                    = [
    "${var.environment}-${var.project_name}-basic-model.fifo",
    "${var.environment}-${var.project_name}-hd-model.fifo",
    "${var.environment}-${var.project_name}-text-to-3d-model.fifo"
  ]
  content_based_deduplication = true
  delay_seconds              = 0
  visibility_timeout_seconds = 45
  message_retention_seconds  = 86400
  receive_wait_time_seconds  = 10
}



# # module basic_model_ecs_cluster{
# #   source ="./modules/ecs-ai-model"
# #  name                  = "hd-model"
# #  vpc_id                = module.vpc.vpc_id
# #  public_subnet_ids     = module.vpc.public_subnets
# #  private_subnet_ids    = module.vpc.private_subnet_ids
# #  image                 = "976193246727.dkr.ecr.us-east-1.amazonaws.com/backend-app:latest"
# #  container_port        = 80
# #  key_name              = "ec2-key"
# #  sqs_name              = "testing-model.fifo"
# #  region                = "us-east-1"
# #  cpu                   = "2048"
# #  memory                = "8192"
# #  max_capacity          = 4
# #  min_capacity          = 1
# #  instance_type = "t3.medium"
# # }


# module ecs{
#   vpc_id = module.vpc.vpc_id
#   public_subnet_ids = module.vpc.public_subnets
#   repository_url = module.ecr-backend-app.repository_url
#   region = "us-east-1"
#   private_subnet_ids = module.vpc.private_subnet_ids
#   source="./modules/ecs"
#   cluster_name="${var.environment}-cluster-${var.project_name}"
#   iam_role_prefix="ecs-node-role"
#   iam_profile_prefix="ecs-node-profile"
#   sg_prefix="ecs-node-sg"
#   launch_template_prefix="ecs-ec2"
#   instance_type="t3.medium"
#   asg_prefix="ecs-asg"
#   asg_min_size="1"
#   asg_max_size="3"
#   capacity_provider_name="ec2_capacity_provider"
#   max_scaling_step_size="2"
#   min_scaling_step_size="1"
#   target_capacity="100"
#   capacity_provider_base="1"
#   ecs_exec_role_name_prefix="ecs-exec-role"
#   ecs_task_role_name_prefix="ecs-task-role"
#   ecs_log_group= "/ecs/jelwelbench/" 
#   task_family        = "${var.environment}-backend-${var.project_name}"
#   container_name     = "${var.environment}-backend-${var.project_name}-continer"
#   container_port =80
#   host_port=80
#   task_cpu = 256
#   task_memory = 256
#   network_mode = "bridge"
#   compatibilities=["EC2"]
#   container_environment = [
#   {
#     name  = "ENV"
#     value = "${var.environment}"
#   }]
# target_value = 75
# scale_out_cooldown= 300
# ecs_task_security_group="${var.environment}-backend-${var.project_name}-ecs-sg"
# alb_security_name="${var.environment}-backend-${var.project_name}-alb-sg"
# scale_in_cooldown=300
# scaling_policy_name="${var.environment}-backend-${var.project_name}-service-scaling-policy"
# loadbalancer_name="${var.environment}-backend-${var.project_name}-alb"
# alb_target_group_name="${var.environment}-be"
# ecs_service_max_capacity=5
# ecs_service_min_capacity=1
# ecs_service_name="${var.environment}-backend-${var.project_name}-service"
# }


