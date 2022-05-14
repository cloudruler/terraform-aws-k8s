# data "azurerm_public_ip" "pip_k8s" {
#   name                = var.cluster_public_ip
#   resource_group_name = var.connectivity_resource_group_name
# }

data "aws_subnets" "this" {
  filter {
    name   = "vpc-id"
    values = [aws_vpc.vpc.id]
  }
}

resource "aws_lb" "lb_k8s" {
  name               = "lb-k8s"
  #internal           = false
  load_balancer_type = "network"
  subnets            = data.aws_subnets.this.ids
  #enable_cross_zone_load_balancing = true
  #enable_deletion_protection = true
}

resource "aws_lb_target_group" "target_group_443" {
  vpc_id      = aws_vpc.vpc.id
  protocol    = "TCP"
  port        = 443
  #stickiness = []

  depends_on = [
    aws_lb.lb_k8s
  ]

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_lb_listener" "listener_443" {
  load_balancer_arn = aws_lb.lb_k8s.arn
  protocol          = "TCP"
  port              = 443

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group_443.arn
  }
}
