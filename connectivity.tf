
data "aws_vpc_ipam_pool" "ipam_pool" {
}

resource "aws_vpc" "vpc" {
  ipv4_ipam_pool_id   = data.aws_vpc_ipam_pool.ipam_pool.id
  ipv4_netmask_length = var.vpc_netmask_length
  tags = merge({
    name = "cluster-vpc"
  }, var.tags)
}

resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.vpc.id
  availability_zone = "us-west-1a"
  map_public_ip_on_launch = true
  tags = merge({
    name = "lb_public_subnet"
  }, var.tags)
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.vpc.id
  availability_zone = "us-west-1a"
  map_public_ip_on_launch = false
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

resource "aws_key_pair" "brianmoore" {
    key_name = "brianmoore"
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC+HxnuN1D7vtkxABtAxRizT2RrUha45M3qBABWKBJAEJqev9gUC0zRxAwW6Eh8lhfv9jKcnekMkOZNPrR/Bx5cuv0hACDxF4nb2trcFTK2IOuaGidk3zld71jQYDnpVes9BSqcMkn9nmx8Nl7p5KPt1foTSezdZq/neiOZ/vV5r8iPmSOwxigYFP2G70P2dMFTY+KyoWDk60WAjr2g6EHSdI4GgR6kghgMAcVuljnseDJVLmYn8I/B2FSXH7APtd0h6J673S8wPZuNzIEYzm/KEobBn0EpnhyqfOjN5VLdNOUGpXb/VPNXeKaB3KoOzEh20FkaVJmNXlN0WKC1hyCl brian@DESKTOP-SFIVOEU"
}