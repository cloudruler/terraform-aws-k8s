resource "aws_network_interface" "nic" {
  for_each = var.master_nodes_config
  subnet_id   = aws_subnet.private_subnet.id
  tags = {
    name = "master_node-${each.key}-primary_network_interface"
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "inst" {
  for_each = var.master_nodes_config
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.large"
  key_name = var.key_pair_id
  network_interface {
    network_interface_id = aws_network_interface.nic[each.key].id
    device_index         = 0
  }

  credit_specification {
    cpu_credits = "unlimited"
  }

  tags = {
    name = "master_node-${each.key}-primary_network_interface"
  }
  user_data_base64 = base64gzip(templatefile("${var.resources_path}/cloud-config.yaml", {
    node_type       = "master"
    action          = each.key == "prime" ? "init" : "join"
    admin_username  = var.admin_username
    crio_version    = var.crio_version
    crio_os_version = var.crio_os_version
    certificates    = { for cert_name in var.certificate_names : cert_name => data.azurerm_key_vault_certificate.kv_certificate[cert_name].thumbprint }
    helm_version                 = var.helm_version
    configs_kubeadm = base64gzip(templatefile("${var.resources_path}/configs/kubeadm-config.yaml", {
      node_type                    = "master"
      action                       = "master"
      bootstrap_token              = "" #data.azurerm_key_vault_secret.kv_sc_bootstrap_token.value
      api_server_name              = var.api_server_name
      discovery_token_ca_cert_hash = "" #data.azurerm_key_vault_secret.kv_sc_discovery_token_ca_cert_hash.value
      k8s_service_subnet           = var.k8s_service_subnet
      cluster_dns                  = var.cluster_dns
      pod_subnet_cidr              = var.pods_cidr
    }))
    configs_calico = base64gzip(templatefile("${var.resources_path}/configs/calico.yaml", {
      calico_ipv4pool_cidr = var.pods_cidr
    }))
    # manifests_kube_addon_manager    = base64gzip(file("resources/manifests/kube-addon-manager.yaml"))
    # addons_coredns = base64gzip(templatefile("resources/addons/coredns.yaml", {
    #   cluster_dns = var.cluster_dns
    # }))
    # addons_kube_proxy          = base64gzip(file("resources/addons/kube-proxy.yaml"))
  }))
}

resource "aws_lb_target_group_attachment" "target_group_attachment_443" {
  for_each = var.master_nodes_config
  target_group_arn = aws_lb_target_group.target_group_443.arn
  target_id        = aws_instance.inst[each.key].id
  port             = 6443
}
