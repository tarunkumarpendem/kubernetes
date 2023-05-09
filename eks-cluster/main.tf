resource "aws_ecr_repository" "openmrs_ecr" {
    count = "${terraform.workspace == "dev" ? 1 : 0}" 
    name = var.ecr_details.registry_name
    image_tag_mutability = "IMMUTABLE"
    image_scanning_configuration {
      scan_on_push = var.ecr_details.scan_on_push
    }
    tags = {
      "Name" = var.ecr_details.registry_tags[0]
      "Environment"  = var.ecr_details.registry_tags[1]
    }
}


resource "aws_vpc" "eks_vpc" {
  count = "${terraform.workspace == "dev" ? 1 : 0}"
  cidr_block = var.network_details.vpc_cidr
  tags = {
    "Name" = var.network_details.vpc_tags[0]
    "Environment" = var.network_details.vpc_tags[1]
    "Purpose" = var.network_details.vpc_tags[2]
  }
}

resource "aws_subnet" "eks_subnets" {
  count = "${terraform.workspace == "dev" ? 3 : 0}"
  cidr_block = var.network_details.subnet_cidrs[count.index]
  availability_zone = var.network_details.availability_zones[count.index]
  vpc_id = aws_vpc.eks_vpc[0].id
  map_public_ip_on_launch = var.instance_details.enable_public_ip_address
  tags = {
    "Name" = var.network_details.subnet_names[count.index]
    "Environment" = var.network_details.subnet_tags[0]
    "Purpose" = var.network_details.subnet_tags[1]
    "kubernetes.io/cluster/dev_eks_cluster_For_Dev"  = var.network_details.subnet_tags[2]
  }
}


resource "aws_internet_gateway" "eks_igw" {
  count = "${terraform.workspace == "dev" ? 1 : 0}"
  vpc_id = aws_vpc.eks_vpc[0].id
  tags = {
    "Name" = var.network_details.igw_tags[0]
    "Environment" = var.network_details.igw_tags[1]
    "Purpose" = var.network_details.igw_tags[2]
  } 
}

resource "aws_route_table" "eks_rt" {
  count = "${terraform.workspace == "dev" ? 1 : 0}"
  vpc_id = aws_vpc.eks_vpc[0].id
  tags = {
    "Name" = var.network_details.route_table_tags[0]
    "Environment" = var.network_details.route_table_tags[1]
    "Purpose" = var.network_details.route_table_tags[2]
  }
}

resource "aws_route" "igw_route" {
  count = "${terraform.workspace == "dev" ? 1 : 0}"
  route_table_id = aws_route_table.eks_rt[0].id
  destination_cidr_block = var.network_details.destination_cidr
  gateway_id = aws_internet_gateway.eks_igw[0].id
}


resource "aws_route_table_association" "subnets_assc" {
  count = "${terraform.workspace == "dev" ? 3 : 0}"
  subnet_id = aws_subnet.eks_subnets[count.index].id
  route_table_id = aws_route_table.eks_rt[0].id
}


resource "aws_security_group" "eks_security_group" {
  count = "${terraform.workspace == "dev" ? 1 : 0}"
  vpc_id = aws_vpc.eks_vpc[0].id
  name = var.network_details.security_group_name[0]
  description = "Opening ssh"
  ingress {
    description      = "TLS from VPC"
    from_port        = 0
    to_port          = 65535
    protocol         = "TCP"
    cidr_blocks      = [ var.network_details.destination_cidr ]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [ var.network_details.destination_cidr ]
  } 
}

resource "aws_security_group" "kubectl_security_group" {
  count = "${terraform.workspace == "dev" ? 1 : 0}"
  vpc_id = aws_vpc.eks_vpc[0].id
  name = var.network_details.security_group_name[1]
  description = "Opening ssh"
  ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "TCP"
    cidr_blocks      = [ var.network_details.destination_cidr ]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [ var.network_details.destination_cidr ]
  } 
}

resource "aws_instance" "kubectl" {
  count = "${terraform.workspace == "dev" ? 1 : 0}"
  ami = var.instance_details.ami_id
  key_name = var.instance_details.key_pair
  instance_type = var.instance_details.instance_type
  security_groups = [ aws_security_group.kubectl_security_group[0].id ]
  availability_zone = var.network_details.availability_zones[0]
  subnet_id = aws_subnet.eks_subnets[0].id
  associate_public_ip_address = var.instance_details.enable_public_ip_address
  tags = {
    "Name" = var.instance_details.instance_tags[0]
    "Environment" = var.instance_details.instance_tags[1]
    "Purpose" = var.instance_details.instance_tags[2] 
  }
  provisioner "remote-exec" {
    connection {
      user = var.instance_details.provisioner_user_name
      type = var.instance_details.provisioner_connection_type
      host = self.public_ip
      private_key = file("~/.ssh/id_rsa")
    }
    inline = [ 
      "git clone https://github.com/tarunkumarpendem/scripting.git",
      "cd scripting",
      "sh kubectl.sh",
      "aws eks update-kubeconfig --region us-east-1 --name dev_eks_cluster_For_Dev",
      "kubectl apply -k github.com/kubernetes-sigs/aws-ebs-csi-driver/deploy/kubernetes/overlays/stable/?ref=master"
      # "wget https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/aws/deploy.yaml to deploy namespace, serviceaccounts, configmap, clusterroles, clusterrolebindings, roles, rolebindings, services, deployments, ingressclasses, and validatingwebhookconfigurations",
      # "kubectl apply -f deploy.yaml"
     ]
  }
  depends_on = [ 
    aws_eks_node_group.eks_node_group1
  ]
}


data "aws_iam_role" "eks_cluster_role" {
  name = var.data_source.cluster_iam_role_name
}

data "aws_iam_role" "node_group_role" {
  name = var.data_source.node_group_iam_role_name
}

# data "aws_iam_policy_document" "eks_policy" {
#   statement {
#     effect    = "Allow"
#     actions   = ["ec2:*"]
#     resources = ["*"]
#   }
#   statement {
#     effect = "Allow"
#     actions = [ 
#       "ecr:GetAuthorizationToken",
#       "ecr:BatchCheckLayerAvailability",
#       "ecr:GetDownloadUrlForLayer",
#       "ecr:GetRepositoryPolicy",
#       "ecr:DescribeRepositories",
#       "ecr:ListImages",
#       "ecr:DescribeImages",
#       "ecr:BatchGetImage",
#       "ecr:GetLifecyclePolicy",
#       "ecr:GetLifecyclePolicyPreview",
#       "ecr:ListTagsForResource",
#       "ecr:DescribeImageScanFindings" 
#     ]
#     resources = ["*"]
#   }
#   statement {
#     effect = "Allow"
#     actions = [ 
#       "ec2:AssignPrivateIpAddresses",
#       "ec2:AttachNetworkInterface",
#       "ec2:CreateNetworkInterface",
#       "ec2:DeleteNetworkInterface",
#       "ec2:DescribeInstances",
#       "ec2:DescribeTags",
#       "ec2:DescribeNetworkInterfaces",
#       "ec2:DescribeInstanceTypes",
#       "ec2:DetachNetworkInterface",
#       "ec2:ModifyNetworkInterfaceAttribute",
#       "ec2:UnassignPrivateIpAddresses"
#     ]
#     resources = ["*"]
#   }
# }

# resource "aws_iam_role" "node_group_role" {
#   count = "${terraform.workspace == "dev" ? 1 : 0}"
#   name = var.data_source.node_group_iam_role_name
#   assume_role_policy = data.aws_iam_policy_document.eks_policy.json
#   tags = {
#     "Name" = var.data_source.node_group_role_tags[0]
#     "Environment" = var.data_source.node_group_role_tags[1]
#   }
#   depends_on = [ 
#     data.aws_iam_policy_document.eks_policy 
#   ]
# }

# resource "aws_iam_role_policy_attachment" "policy_attach" {
#   count = "${terraform.workspace == "dev" ? 1 : 0}"
#   role       = aws_iam_role.node_group_role[0].name
#   policy_arn = data.aws_iam_policy_document.eks_policy.json
#   depends_on = [ 
#     aws_iam_role.node_group_role 
#   ]
# }



resource "aws_eks_cluster" "dev_eks_cluster" {
  count = "${terraform.workspace == "dev" ? 1 : 0}"
  name = var.cluster_info.cluster_name
  role_arn = data.aws_iam_role.eks_cluster_role.arn
  version = var.cluster_info.cluster_version
  vpc_config {
    subnet_ids = [ aws_subnet.eks_subnets[0].id, aws_subnet.eks_subnets[1].id, aws_subnet.eks_subnets[2].id ]
    endpoint_public_access = true
    endpoint_private_access = true
    security_group_ids = [ aws_security_group.eks_security_group[0].id ]
  }
  kubernetes_network_config {
    ip_family = "ipv4"
    service_ipv4_cidr = "10.10.0.0/16"
  }
  tags = {
    "Name" = var.cluster_info.eks_cluster_tags[0]
    "Environment" = var.cluster_info.eks_cluster_tags[1]
  }
  depends_on = [ 
    data.aws_iam_role.eks_cluster_role
  ]
}

resource "aws_eks_node_group" "eks_node_group1" {
  count = "${terraform.workspace == "dev" ? 1 : 0}"
  cluster_name = aws_eks_cluster.dev_eks_cluster[0].name
  node_group_name = var.node_group_details.node_group_name
  node_role_arn = data.aws_iam_role.node_group_role.arn
  subnet_ids = [ aws_subnet.eks_subnets[0].id, aws_subnet.eks_subnets[1].id, aws_subnet.eks_subnets[2].id ]
  scaling_config {
    max_size = var.node_group_details.max_number_of_nodes
    min_size = var.node_group_details.min_number_of_nodes
    desired_size = var.node_group_details.desired_number_of_nodes
  }
  instance_types = [ var.node_group_details.instance_types ]
  ami_type = var.node_group_details.ami_type
  capacity_type = var.node_group_details.instance_model
  disk_size = var.node_group_details.disk_size
  remote_access {
    ec2_ssh_key = var.node_group_details.ssh_key
    source_security_group_ids = [ aws_security_group.eks_security_group[0].id ]
  }
  tags = {
    "Name" = var.node_group_details.node_group_tags[0]
    "Environment" = var.node_group_details.node_group_tags[1]
  }
  depends_on = [ 
    aws_eks_cluster.dev_eks_cluster,
    data.aws_iam_role.node_group_role
  ]
}

# source <(kubectl completion bash)
# echo "source <(kubectl completion bash)" >> ~/.bashrc
# aws eks update-kubeconfig --region us-east-1 --name dev_eks_cluster_For_Dev
# git clone https://github.com/tarunkumarpendem/kubernetes.git
# cd kubernetes
# aws eks update-cluster-version --region us-east-1 --name dev_eks_cluster_For_Dev --kubernetes-version "1.26"
# aws eks update-nodegroup-version --cluster-name dev_eks_cluster_For_Dev --nodegroup-name dev_node_group_1 --region us-east-1
# wget https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/aws/deploy.yaml to deploy namespace, serviceaccounts, configmap, clusterroles, clusterrolebindings, roles, rolebindings, services, deployments, ingressclasses, and validatingwebhookconfigurations
# kubectl apply -f deploy.yaml
