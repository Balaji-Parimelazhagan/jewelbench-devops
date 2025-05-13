################################# env #######################################################
region               = "us-east-1"
environment          = "qa"
project_name         = "jewelbench"
AWS_TAGS = {
  project        = "jewelbench"
  Owner          = "Team"
  Department     = "IT"
}


################################## Create VPC ################################################
vpc_cidr             = "10.100.0.0/16"
public_subnets_cidr  = ["10.100.1.0/24", "10.100.2.0/24", "10.100.3.0/24"]
private_subnets_cidr = ["10.100.11.0/24", "10.100.12.0/24", "10.100.13.0/24"]
db_subnets_cidr      = ["10.100.14.0/24", "10.100.15.0/24"]
availability_zones   = ["us-east-1a", "us-east-1b", "us-east-1c"]
create_eip = true


bucket_name       = "jewelbench"
enable_versioning = true
acl               = "private" #private → Only the bucket owner can access it.
object_ownership  = "BucketOwnerPreferred" #Objects are owned by the bucket owner



frontend_bucket_name    = "jewelbench"
frontend_bucket_regional_domain_name = "jewelbench.s3.us-east-1.amazonaws.com"

allowed_cidrs   = ["10.0.0.0/16"]
db_name         = "qa_jewelbench_be"
db_user         = "jewelbench"
db_password     = "Jewelbench_QA_2025" 
db_storage_type = "gp2"
db_engine       = "postgres"
engine_version  = "15.7"
instance_class  = "db.m5.large"


redis_name         = "qa"
redis_node_type    = "cache.t3.medium"
redis_num_nodes    = 1
