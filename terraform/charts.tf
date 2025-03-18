provider "helm" {
  kubernetes = {
    config_path = "./config"
  }
}

provider "kubernetes" {
  config_path = "./config"
}

provider "kubectl" {
  config_path = "./config"
}

provider "null" {
  # Configuration options
}
##################################
# cert-manager
##################################
resource "kubernetes_namespace" "cert_manager" {
  metadata {
    name = "cert-manager"
  }
}

resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "v1.17.1"
  namespace  = "cert-manager"

  set_list = [
    {
      name  = "installCRDs"
      value = true
    }
  ]
  depends_on = [kind_cluster.kind]
}
##################################
# Metrics Server
##################################
resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server"
  chart      = "metrics-server"
  version    = "3.12.2"
  namespace  = "kube-system"

  values = [
    <<-YAML
    args:
      - --kubelet-insecure-tls
    YAML
  ]


  depends_on = [kind_cluster.kind]
}

##################################
# Rabbitmq
##################################

resource "kubernetes_namespace" "rabbitmq" {
  metadata {
    name = "rabbitmq"
  }
}

# Apply the RabbitMQ Cluster Operator directly
resource "null_resource" "rabbitmq_cluster_operator" {
  provisioner "local-exec" {
    command = "kubectl --kubeconfig=./config apply -f 'https://github.com/rabbitmq/cluster-operator/releases/${var.rabbitmq_chart_version}/download/cluster-operator.yml'"
  }

  depends_on = [kind_cluster.kind]
}

locals {
  rabbitmq_definitions = {
    apiVersion = "v1"
    kind       = "ConfigMap"
    metadata = {
      name      = "definitions"
      namespace = "rabbitmq"
    }
    data = {
      "definitions.json" = jsonencode({
        product_name = "RabbitMQ"
        users = [
          {
            name     = "tmsrabbitmq"
            password = "tmsrabbitmq"
            tags     = "administrator"
            limits   = {}
          },
        ]
        vhosts = [
          {
            name = "/"
          }
        ]
        permissions = [
          {
            user      = "tmsrabbitmq"
            vhost     = "/"
            configure = ".*"
            write     = ".*"
            read      = ".*"
          }
        ]
        topic_permissions = []
        parameters        = []
        global_parameters = [
          {
            name  = "cluster_name"
            value = "rabbit@73cf1fdf05d2"
          },
          {
            name  = "internal_cluster_id"
            value = "rabbitmq-cluster-id-j-jeqGlk6rJYvqR_Tb06yw"
          }
        ]
        policies  = []
        queues    = []
        exchanges = []
        bindings  = []
      })
    }
  }
}

resource "kubernetes_manifest" "rabbitmq_definitions" {
  manifest = local.rabbitmq_definitions
  depends_on = [
    null_resource.rabbitmq_cluster_operator,
  ]
}

# Create the RabbitMQ cluster

locals {
  rabbitmq_cluster_yaml = <<-YAML
    apiVersion: rabbitmq.com/v1beta1
    kind: RabbitmqCluster
    metadata:
      name: rabbit
      namespace: rabbitmq
    spec:
      replicas: 3
      resources:
        limits:
          cpu: "0.5"
          memory: "250Mi"
        requests:
          cpu: "0.2"
          memory: "150Mi"
      rabbitmq:
        additionalConfig: |
          load_definitions = /etc/rabbitmq/definitions.json
          cluster_partition_handling = pause_minority
          vm_memory_high_watermark_paging_ratio = 0.99
          disk_free_limit.relative = 1.0
          collect_statistics_interval = 5000
        additionalPlugins:
          - rabbitmq_management
          - rabbitmq_federation
          - rabbitmq_federation_management
          - rabbitmq_stream
          - rabbitmq_stream_management
      override:
        statefulSet:
          spec:
            template:
              spec:
                containers:
                - name: rabbitmq
                  volumeMounts:
                  - mountPath: /etc/rabbitmq/definitions.json
                    subPath: definitions.json
                    name: definitions
                volumes:
                - name: definitions
                  configMap:
                    name: definitions # Name of the ConfigMap which contains definitions you wish to import
  YAML
}
resource "kubectl_manifest" "rabbitmq" {
  yaml_body = local.rabbitmq_cluster_yaml
  depends_on = [
    null_resource.rabbitmq_cluster_operator,
    kubernetes_manifest.rabbitmq_definitions,
  ]
  lifecycle {
    ignore_changes = [
      yaml_body,
    ]
  }
}

##################################
# Otel Collector
##################################


resource "kubernetes_service_account_v1" "otel_collector_account" {
  metadata {
    name      = "otel-collector-account"
    namespace = "observability"
  }
}

resource "kubernetes_cluster_role_v1" "otel_collectorrole" {
  metadata {
    name = "otel-collector-role"
  }

  rule {
    api_groups = [""]
    resources  = ["pods", "namespaces"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_cluster_role_binding_v1" "otel_collectorrolebinding" {
  metadata {
    name = "otel-collector-role-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role_v1.otel_collectorrole.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.otel_collector_account.metadata[0].name
    namespace = "observability"
  }

  depends_on = [kubernetes_service_account_v1.otel_collector_account]
  lifecycle {
    ignore_changes = [role_ref[0].name]
  }
}



resource "kubernetes_config_map_v1" "otel_collector_config" {
  metadata {
    name      = "otel-collector-config"
    namespace = "observability"
  }

  data = {
    "config.yaml" = <<-YAML
      exporters:
        prometheusremotewrite:
            endpoint: "http://prometheus-service.observability.svc:9090/api/v1/write"
      processors:
        batch:
          send_batch_max_size: 32768
          timeout: 400ms
        memory_limiter:
          check_interval: 5s
          limit_percentage: 80
          spike_limit_percentage: 25
        k8sattributes:
          passthrough: false
          auth_type: "serviceAccount"
          pod_association:
            - sources:
              - from: resource_attribute
                name: k8s.pod.ip
          extract:
            metadata:
              - k8s.pod.name
            labels:
              - tag_name: kube_pod_index
                key: apps.kubernetes.io/pod-index
                from: pod
      receivers:
        otlp:
          protocols:
            grpc:
              endpoint: $${env:MY_POD_IP}:4317
            http:
              endpoint: $${env:MY_POD_IP}:4318
        prometheus:
          config:
            scrape_configs:
              - job_name: "otel-collector"
                scrape_interval: 10s
                static_configs:
                  - targets: ["$${env:MY_POD_IP}:8888"]
              - job_name: "rabbitmq-no-k8s-attributes"
                scrape_interval: 20s
                static_configs:
                  - targets: ["rabbit.rabbitmq.svc.cluster.local:15692"]
                  scrape—configs :
              - job-name: "rabbitmq"
                scrape—interval: 20s
                kubernetes—sd-configs :
                  - role: pod
                    namespaces :
                      names :
                      - rabbitmq
                 relabel_configs :
                  - source_labels: [__meta_kubernetes_pod_name]
                    separator: ;
                    regex: rabbit-server-.*
                    target_label: pod
                    replacement: $$1
                    action: replace
                  - source_labels: [__meta_kubernetes_pod_container_name]
                    action: keep
                    regex: 'rabbit-server-.*'
                  - source_labels: [__address__]
                    action: replace
                    regex: ([^:]+):.*
                    replacement: $$1:15692
                    target_label: __address__
      extensions:
        health_check:
          endpoint: $${env:MY_POD_IP}:13133
      service:
        extensions: [health_check, basicauth/server]
        pipelines:
          traces:
            receivers: [otlp]
            processors: [batch, memory_limiter]
            exporters: []
          metrics:
            receivers: [otlp, prometheus]
            processors: [batch, memory_limiter, k8sattributes]
            exporters: [prometheusremotewrite]
          logs:
            receivers: [otlp]
            processors: [batch, memory_limiter]
            exporters: []
    YAML
  }

}

resource "helm_release" "otel_collector" {
  name       = "otel-collector"
  repository = "https://open-telemetry.github.io/opentelemetry-helm-charts"
  chart      = "opentelemetry-collector"
  version    = "0.93.0" # collector version 0.102.0
  namespace  = "observability"

  set_list = [
    {
      name  = "configMap.enabled"
      value = true
    },
    {
      name  = "configMap.name"
      value = "otel-collector-config"
    },
    {
      name  = "image.repository"
      value = "otel/opentelemetry-collector-contrib"
    },
    {
      name  = "mode"
      value = "deployment"
    }
  ]


  depends_on = [kind_cluster.kind, kubernetes_service_account_v1.otel_collector_account, kubernetes_config_map_v1.otel_collector_config]
  lifecycle {
    ignore_changes = [set[0].value, set[1].value]
  }
}
