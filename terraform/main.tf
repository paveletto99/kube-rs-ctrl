#==================================================
# PROVIDER
#==================================================
# https://registry.terraform.io/providers/tehcyx/kind/latest/docs/resources/cluster
provider "kind" {
  # config = file("${path.module}/config.yaml")
}

locals {
  k8s_config_path = pathexpand("${path.module}/config")
}

resource "kind_cluster" "kind" {
  name            = var.kind_cluster_name
  kubeconfig_path = local.k8s_config_path
  node_image      = var.kind_node_image
  wait_for_ready  = true

  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    containerd_config_patches = [
      <<-TOML
      [plugins."io.containerd.grpc.v1.cri".registry.mirrors."localhost:${var.kind_registry_port}"]
        endpoint = ["http://${var.kind_registry_name}:${var.kind_registry_port}"]
      TOML
    ]

    node {
      role = "control-plane"
      kubeadm_config_patches = [
        <<-YAML
        kind: InitConfiguration
        nodeRegistration:
          kubeletExtraArgs:
            node-labels: "ingress-ready=true"
        YAML
      ]
      extra_port_mappings {
        container_port = 80
        host_port      = 80
        protocol       = "TCP"
        listen_address = "0.0.0.0"
      }
      extra_port_mappings {
        container_port = 443
        host_port      = 443
        protocol       = "TCP"
        listen_address = "0.0.0.0"
      }
    }
    node {
      role = "worker"
    }
    # node {
    #   role = "worker"
    # }
    # node {
    #   role = "worker"
    # }
  }
}