module "vpc1" {
  source     = "git::https://github.com/cloudposse/terraform-aws-vpc.git?ref=master"
  namespace  = "eg"
  stage      = "test-1"
  name       = "vpc1"
  cidr_block = "10.0.0.0/20"
}


module "vpc2" {
  source     = "git::https://github.com/cloudposse/terraform-aws-vpc.git?ref=master"
  namespace  = "eg"
  stage      = "test-2"
  name       = "vpc2"
  cidr_block = "10.0.0.0/20"
}


module "vpc3" {
  source     = "git::https://github.com/cloudposse/terraform-aws-vpc.git?ref=master"
  namespace  = "eg"
  stage      = "test-3"
  name       = "vpc3"
  cidr_block = "10.0.0.0/20"
}

locals {
  private_cidr_block_vpc1 = cidrsubnet(module.vpc1.vpc_cidr_block, 1, 1)
  
  private_cidr_block_vpc2 = cidrsubnet(module.vpc2.vpc_cidr_block, 1, 1)
  
  public_cidr_block_vpc3  = cidrsubnet(module.vpc3.vpc_cidr_block, 1, 0)
  private_cidr_block_vpc3 = cidrsubnet(module.vpc3.vpc_cidr_block, 1, 1)
}

module "private_subnets-vpc1" {
  source              = "git::https://github.com/cloudposse/terraform-aws-multi-az-subnets.git?ref=master"
  namespace           = "eg"
  stage               = "test-1"
  name                = "ps-vpc1"
  availability_zones  = ["us-east-2a", "us-east-2b", "us-east-2c"]
  vpc_id              = module.vpc1.vpc_id
  cidr_block          = local.private_cidr_block_vpc1
  type                = "private"
}



module "private_subnets-vpc2" {
  source              = "git::https://github.com/cloudposse/terraform-aws-multi-az-subnets.git?ref=master"
  namespace           = "eg"
  stage               = "test-2"
  name                = "ps-vpc2"
  availability_zones  = ["us-east-2a", "us-east-2b", "us-east-2c"]
  vpc_id              = module.vpc2.vpc_id
  cidr_block          = local.private_cidr_block_vpc2
  type                = "private"
}



module "public_subnets-vpc3" {
  source              = "git::https://github.com/cloudposse/terraform-aws-multi-az-subnets.git?ref=master"
  namespace           = "eg"
  stage               = "test-3"
  name                = "pub-vpc3"
  availability_zones  = ["us-east-2a", "us-east-2b"]
  vpc_id              = module.vpc3.vpc_id
  cidr_block          = local.public_cidr_block_vpc3
  type                = "public"
  igw_id              = module.vpc3.igw_id
  nat_gateway_enabled = "true"
}

module "private_subnets-vpc3" {
  source              = "git::https://github.com/cloudposse/terraform-aws-multi-az-subnets.git?ref=master"
  namespace           = "eg"
  stage               = "test-3"
  name                = "pvt-vpc3"
  availability_zones  = ["us-east-2c"]
  vpc_id              = module.vpc3.vpc_id
  cidr_block          = local.private_cidr_block_vpc3
  type                = "private"
  az_ngw_ids          = module.public_subnets-vpc3.az_ngw_ids
}




# vpc peering #

module "vpc_peering-1" {
  source           = "git::https://github.com/cloudposse/terraform-aws-vpc-peering.git?ref=master"
  namespace        = "eg"
  stage            = "test-1"
  name             = "peering-1"
  requestor_vpc_id = module.vpc1.vpc_id
  acceptor_vpc_id  = module.vpc3.vpc_id
}

module "vpc_peering-2" {
  source           = "git::https://github.com/cloudposse/terraform-aws-vpc-peering.git?ref=master"
  namespace        = "eg"
  stage            = "test-2"
  name             = "peering-2"
  requestor_vpc_id = module.vpc2.vpc_id
  acceptor_vpc_id  = module.vpc3.vpc_id
}

module "vpc_peering-3" {
  source           = "git::https://github.com/cloudposse/terraform-aws-vpc-peering.git?ref=master"
  namespace        = "eg"
  stage            = "test-3"
  name             = "peering-3"
  requestor_vpc_id = module.vpc1.vpc_id
  acceptor_vpc_id  = module.vpc2.vpc_id
}


# ec2 instances in public and private subnets #

module "private_instance_vpc1" {
  source                      = "git::https://github.com/cloudposse/terraform-aws-ec2-instance.git?ref=master"
  ssh_key_pair                = var.ssh_key_pair
  vpc_id                      = module.vpc1.vpc_id
  subnet                      = module.private_subnets-vpc1.subnet_id
  associate_public_ip_address = true
  name                        = "private-instance"
  namespace                   = "eg"
  stage                       = "test"
  allowed_ports               = [22, 80, 443]
}

module "public_instance_vpc3" {
  source                      = "git::https://github.com/cloudposse/terraform-aws-ec2-instance.git?ref=master"
  ssh_key_pair                = var.ssh_key_pair
  vpc_id                      = module.vpc3.vpc_id
  subnet                      = module.public_subnets-vpc3.subnet_id
  associate_public_ip_address = true
  name                        = "public-instance"
  namespace                   = "eg"
  stage                       = "test"
}




