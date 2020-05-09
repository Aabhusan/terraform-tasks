output "private_az_subnet_ids-vpc2" {
  value = module.private_subnets-vpc2.az_subnet_ids
}

output "private_az_subnet_ids-vpc1" {
  value = module.private_subnets-vpc1.az_subnet_ids
}

output "private_az_subnet_ids-vpc3" {
  value = module.private_subnets-vpc3.az_subnet_ids
}

output "public_az_subnet_ids-vpc3" {
  value = module.public_subnets-vpc3.az_subnet_ids
}

