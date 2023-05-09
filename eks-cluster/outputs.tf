output "ecr_url" {
    value = aws_ecr_repository.openmrs_ecr[0].repository_url
}

output "ecr_arn" {
    value = aws_ecr_repository.openmrs_ecr[0].arn
}

output "vpc_id" {
    value = aws_vpc.eks_vpc[0].id
}

output "subnet1_id" {
    value = aws_subnet.eks_subnets[0].id
}

output "subnet2_id" {
    value = aws_subnet.eks_subnets[1].id
}

output "subnet3_id" {
    value = aws_subnet.eks_subnets[2].id
}


output "igw_id" {
    value = aws_internet_gateway.eks_igw[0].id
}

output "rt_id" {
    value = aws_route_table.eks_rt[0].id
}

output "rt_assc_id_1" {
    value = aws_route_table_association.subnets_assc[0].id 
}

output "rt_assc_id_2" {
    value = aws_route_table_association.subnets_assc[1].id 
}

output "rt_assc_id_3" {
    value = aws_route_table_association.subnets_assc[2].id 
}

output "sg1_id" {
    value = aws_security_group.eks_security_group[0].id
}

output "sg2_id" {
    value = aws_security_group.kubectl_security_group[0].id
}

output "instance_id" {
    value = aws_instance.kubectl[0].id 
}

# output "node_group_role_arn" {
#     value = aws_iam_role.node_group_role[0].arn 
# }

output "eks_cluster_id" {
    value = aws_eks_cluster.dev_eks_cluster[0].cluster_id
}

output "eks_cluster_name" {
    value = aws_eks_cluster.dev_eks_cluster[0].id
}

output "eks_cluster_version" {
    value = aws_eks_cluster.dev_eks_cluster[0].platform_version
}

output "eks_cluster_vpc" {
    value = aws_eks_cluster.dev_eks_cluster[0].vpc_config
}

output "cluster_status" {
    value = aws_eks_cluster.dev_eks_cluster[0].status
}

output "node_group_id" {
    value = aws_eks_node_group.eks_node_group1[0].id
}

output "node_group_resources" {
    value = aws_eks_node_group.eks_node_group1[0].resources
}

output "node_group_status" {
    value = aws_eks_node_group.eks_node_group1[0].status
}
output "instance_public_ip" {
    value = aws_instance.kubectl[0].public_ip
}
