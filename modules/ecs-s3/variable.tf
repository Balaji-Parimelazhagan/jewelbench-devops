variable "name" {

}
variable "vpc_id" {

}
variable "public_subnet_ids" { 
    type = list(string) 
    }
variable "private_subnet_ids" { 
    type = list(string) 
    }
variable "container_port" {

}
variable "image" {

}
variable "key_name" {

}
variable "sqs_name" {

}
variable "sqs_arn" {

}
variable "aws_region" {
  
}
