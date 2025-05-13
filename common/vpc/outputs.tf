output "vpc_id" {
  value = aws_vpc.this.id
}

output "public_subnets" {
  value = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  # value = [for subnet in aws_subnet.private : subnet.id]
  value = aws_subnet.private[*].id
}






