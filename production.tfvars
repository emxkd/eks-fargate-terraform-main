region                      = "ap-south-1"
vpc_name                    = "eks_rds"
vpc_cidr                    = "10.2.0.0/16"
eks_cluster_name            = "eks_cluster"
cidr_block_igw              = "0.0.0.0/0"
node_group_name             = "eks_ng"
ng_instance_types           = [ "t2.micro" ]
disk_size                   = 10
desired_nodes               = 2
max_nodes                   = 2
min_nodes                   = 1
fargate_profile_name        = "eks_fargate"
kubernetes_namespace        = "jenkins"
deployment_name             = "jenkins"
deployment_replicas         = 3

app_labels = { 
    "app" = "wordpress"
    "tier" = "frontend"
    #"Environment" = "${terraform.workspace}"
    }