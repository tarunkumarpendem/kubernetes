variable "region" {
    type = string
    description = "Selecting region in AWS to create resources"
    default = "us-east-1"
}

variable "ecr_details" {
    type = object({
        registry_name = string
        registry_tags = list(string)
        scan_on_push = bool
    })
    description = "Selecting Name for ECR Repository"
    default = {
      registry_name = "openmrs_ecr_repo"
      registry_tags = [ "openmrs_ecr_pvt_repo", "dev" ]
      scan_on_push  = true
    }
}

variable "data_source" {
    type = object({
        # eks_cluster_role = string
        cluster_iam_role_name = string
        node_group_iam_role_name = string
        node_group_role_tags = list(string)
        node_group_iam_role_name = string
    })
    default = {
        # eks_cluster_role = "arn:aws:iam::116710275660:role/eks_role"
        cluster_iam_role_name = "eks_role"
        node_group_iam_role_name = "eks_node_group_role"
        node_group_role_tags = [ "node_group_1_for_dev", "dev" ]
        node_group_iam_role_name  = "node_group_role"
    }
    description = "Cluster arn"
}


variable "network_details" {
    type = object({
        vpc_cidr = string
        vpc_tags = list(string)
        subnet_cidrs = list(string)
        availability_zones = list(string)
        subnet_tags = list(string)
        subnet_names = list(string)
        igw_tags = list(string)
        route_table_tags = list(string)
        security_group_name = list(string)
        destination_cidr = string
    })
    description = "Creating the Network for EKS Cluster"
    default = {
        vpc_cidr = "172.168.0.0/16"
        vpc_tags = [ "eks_vpc", "dev", "for_eks_cluster" ]
        subnet_cidrs = [ "172.168.0.0/24", "172.168.1.0/24", "172.168.2.0/24" ]
        availability_zones = [ "us-east-1a", "us-east-1b", "us-east-1c" ]
        subnet_tags = [ "dev", "for_eks", "shared" ]
        subnet_names = [ "eks_subnet_1_and_kubectl", "eks_subnet_2", "eks_subnet_3" ]
        igw_tags = [ "eks_igw", "dev", "for_eks" ]
        route_table_tags = [ "eks_rt", "dev", "for_eks" ]
        security_group_name = [ "eks_cluster_sg", "kubectl_instance_sg"]
        destination_cidr = "0.0.0.0/0"
    }
}


variable "instance_details" {
    type = object({
      ami_id = string
      key_pair = string
      instance_type = string
      enable_public_ip_address = bool
      instance_tags = list(string)
      provisioner_user_name = string
      provisioner_connection_type = string

    })
    default = {
      ami_id = "ami-0e625d9a5a1694cec"
      key_pair = "standard"
      instance_type = "t2.small"
      enable_public_ip_address = true
      instance_tags = [ "kubectl", "dev", "for_eks_kubectl" ]
      provisioner_user_name = "ubuntu"
      provisioner_connection_type = "ssh"
    }
    description = "Creating an instance for configuring Kubectl"
}


variable "cluster_info" {
    type = object({
      cluster_name = string
      cluster_version = string
      eks_cluster_tags = list(string)
    })
    default = {
      cluster_name = "dev_eks_cluster_For_Dev" 
      cluster_version = "1.24" 
      eks_cluster_tags = [ "dev_cluster", "dev" ]
    }
    description = "EKS Cluster info"
}

variable "node_group_details" {
    type = object({
      node_group_name = string
      ami_type = string
      disk_size = string
      min_number_of_nodes = number
      max_number_of_nodes = number
      desired_number_of_nodes = number 
      ssh_key = string
      instance_types = string
      node_group_tags = list(string)
      instance_model = string
    })
    description = "Selecting node group details"
    default = {
        node_group_name = "dev_node_group_1"
        ami_type = "AL2_x86_64"
        disk_size = "50"
        min_number_of_nodes = 2
        max_number_of_nodes = 5
        desired_number_of_nodes = 2
        ssh_key = "standard"
        instance_types = "t2.large"
        node_group_tags = [ "dev_node_group_1","dev" ] 
        instance_model = "ON_DEMAND"     
    }
}