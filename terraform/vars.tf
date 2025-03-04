# kind provider
terraform {
  required_providers {
    kind = {
      source = "tehcyx/kind"
      version = "0.8.0"
    }
  }
}

variable kind_cluster_name {
  type        = string
  default     = "kind-sdk"
  description = "The name of the kind cluster"
}

variable kind_node_image {
  type        = string
  default     = "kindest/node:v1.32.2@sha256:f226345927d7e348497136874b6d207e0b32cc52154ad8323129352923a3142f"
  description = "The node image of the kind cluster"
}

variable kind_registry_name {
  type        = string
  default     = ""
  description = "The name of the kind registry"
}

variable kind_registry_port {
  type        = string
  default     = ""
  description = "The port of the kind registry"
}

