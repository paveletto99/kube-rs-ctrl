variable "kind_cluster_name" {
  type        = string
  default     = "kind-sdk"
  description = "The name of the kind cluster"
}

variable "kind_node_image" {
  type        = string
  default     = "kindest/node:v1.32.2@sha256:f226345927d7e348497136874b6d207e0b32cc52154ad8323129352923a3142f"
  description = "The node image of the kind cluster"
}

variable "kind_registry_name" {
  type        = string
  default     = ""
  description = "The name of the kind registry"
}

variable "kind_registry_port" {
  type        = string
  default     = ""
  description = "The port of the kind registry"
}

variable "rabbitmq_chart_version" {
  type        = string
  default     = "2.12.1"
  description = "The version of the RabbitMQ chart"
}


terraform {
  required_version = ">=1.3"
  required_providers {
    kind = {
      source  = "tehcyx/kind"
      version = "0.8.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "3.0.0-pre2"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.36.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.19.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.2.3"
    }
  }
}
