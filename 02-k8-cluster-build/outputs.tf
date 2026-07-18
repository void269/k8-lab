output "vpc_id" {
  value = aws_vpc.vpc01.id
  description = "VPC ID"
}

output "vpc_public_subnets" {
  value = aws_subnet.public[*].id
  description = "List of public subnet created"
}

output "vpc_private_subnets" {
  value = aws_subnet.private[*].id
  description = "List of private subnet created"
}