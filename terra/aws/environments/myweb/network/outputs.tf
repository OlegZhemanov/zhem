output "vpc_cidr" {
  value = module.network.vpc_cidr
}

output "vpc_id" {
  value = module.network.vpc_id
}

output "public_subnet_cidr" {
  value = var.public_subnet_cidr
}

output "private_subnet_cidr" {
  value = var.private_subnet_cidr
}

output "private_subnet_cidr_eip" {
  value = var.private_subnet_cidr_eip
}

output "database_subnets_cidr" {
  value = var.database_subnets_cidr
}

output "public_subnet_ids" {
  value = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.network.public_subnet_ids
}

output "private_subnet_ids_eip" {
  value = module.network.private_subnet_ids_eip
}

output "database_subnets_ids" {
  value = module.network.database_subnets_ids
}