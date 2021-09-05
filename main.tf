provider "aws" {
  region = "ap-south-1"
  profile = "Divya"
}


module "network" {
  source              = "./network"
  vpc_name            = var.vpc_name
  vpc_cidr            = var.vpc_cidr
  eks_cluster_name    = var.eks_cluster_name
  cidr_block_igw      = var.cidr_block_igw
}

module "eks_cluster" {
  source              = "./eks/eks_cluster"
  cluster_name        = var.eks_cluster_name
  public_subnets      = module.network.aws_subnets_public
  private_subnets     = module.network.aws_subnets_private
} 

module "eks_node_group" {
  source            = "./eks/eks_node_group"
  eks_cluster_name  = module.eks_cluster.cluster_name
  node_group_name   = var.node_group_name
  subnet_ids        = [ module.network.aws_subnets_private[0], module.network.aws_subnets_private[1] ]
  instance_types    = var.ng_instance_types
  disk_size         = var.disk_size
  desired_nodes     = var.desired_nodes
  max_nodes         = var.max_nodes
  min_nodes         = var.min_nodes
}

module "fargate" {
  source                  = "./eks/fargate"
  eks_cluster_name        = module.eks_cluster.cluster_name
  fargate_profile_name    = var.fargate_profile_name
  subnet_ids              = module.network.aws_subnets_private
  kubernetes_namespace    = var.kubernetes_namespace
}

module "database" {
  source = "infrablocks/rds-postgres/aws"
  version = "0.1.8"

  region = "ap-south-1"
  vpc_id = aws_vpc.vpc.id
  private_subnet_ids = aws_subnet.priv_subnet.*.id
  private_network_cidr = cidrsubnet(aws_vpc.vpc.cidr_block, 8, count.index + length(data.aws_availability_zones.all.names))

  component = "identity-server"
  deployment_identifier = "2f3eddcb"

  database_instance_class = "db.t2.medium"
  database_version = "9.6.8"

  database_name = "identity"
  database_master_user = "admin"
  database_master_password = "divya@1234"
}


module "kubernetes" {
  source                = "./kubernetes"
  region                = var.region
  vpc_id                = module.network.vpc_id
  vpc_cidr              = var.vpc_cidr
  efs_subnet_ids        = module.network.aws_subnets_private
  eks_cluster_name      = module.eks_cluster.cluster_name
  eks_cluster_endpoint  = module.eks_cluster.endpoint
  eks_oidc_url          = module.eks_cluster.oidc_url
  eks_ca_certificate    = module.eks_cluster.ca_certificate
  namespace             = var.kubernetes_namespace
  deployment_name       = var.deployment_name
  replicas              = var.deployment_replicas
  labels                = var.app_labels
  db_name               = var.rds_db_name
  db_address            = module.rds.address
  db_user               = local.db_creds.username
  db_pass               = local.db_creds.password
  namespace_depends_on  = [ module.fargate.id , module.eks_node_group.id ]
}
