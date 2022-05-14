resource "aws_vpc" "vpc" {
  ipv4_ipam_pool_id   = var.ipam_pool_id
  ipv4_netmask_length = var.vpc_netmask_length
  tags = merge({
    name = "cluster-vpc"
  }, var.tags)
}

resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.vpc.id
  availability_zone = "us-west-1a"
  map_public_ip_on_launch = true
  cidr_block = var.public_subnet_cidr
  tags = merge({
    name = "lb_public_subnet"
  }, var.tags)
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.vpc.id
  availability_zone = "us-west-1a"
  map_public_ip_on_launch = false
  cidr_block = var.private_subnet_cidr
  tags = merge({
    name = "lb_private_subnet"
  }, var.tags)
}

resource "aws_security_group" "this" {
  vpc_id      = aws_vpc.vpc.id
}

resource "aws_security_group_rule" "ingress_443" {
  description = "Allow connection between NLB and target"
  security_group_id = aws_security_group.this.id
  from_port         = 443
  to_port           = 443
  protocol          = "TCP"
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

# resource "aws_internet_gateway" "igw" {
#     vpc_id = aws_vpc.vpc.id
#     tags {
#         Name = "igw"
#     }
# }

# resource "aws_route_table" "public_route_table" {
#     vpc_id = aws_vpc.vpc.id
    
#     route {
#         #Associated subnet can reach everywhere
#         cidr_block = "0.0.0.0/0" 
#         #Route table uses this IGW to reach internet
#         gateway_id = aws_internet_gateway.igw.id}
#     }
    
#     tags {
#         Name = "public_route_table"
#     }
# }

# resource "aws_security_group" "ssh-allowed" {
#     vpc_id = aws_vpc.vpc.id
#     egress {
#         from_port = 0
#         to_port = 0
#         protocol = -1
#         cidr_blocks = ["0.0.0.0/0"]
#     }
#     ingress {
#         from_port = 22
#         to_port = 22
#         protocol = "tcp"
#         cidr_blocks = ["0.0.0.0/0"]
#     }
#     ingress {
#         from_port = 80
#         to_port = 80
#         protocol = "tcp"
#         cidr_blocks = ["0.0.0.0/0"]
#     }
#     tags {
#         Name = "ssh_allowed"
#     }
# }
