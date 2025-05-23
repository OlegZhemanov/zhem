output "vpc_id" {
  value = aws_vpc.main.id
}

output "vpc_cidr" {
  value = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  value = aws_subnet.public_subnets[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private_subnets[*].id
}

output "private_subnet_ids_eip" {
  value = aws_subnet.private_subnets_eip[*].id
}

output "database_subnets_ids" {
  value = aws_subnet.database_subnets[*].id
}