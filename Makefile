# 🔮
KIND_CLUSTER_NAME=cluster-dev01
KIND_CREATE_CLUSTER_SCRIPT=$(PWD)/kubernetes/kind/kind-create-cluster-with-registry
KIND_HOST_MOUNT_PATH=$(HOME)/opt/kind-${KIND_CLUSTER_NAME}-pv/
# KIND_KUBECONFIG_DIR=${WINHOME}/.kube
KIND_KUBECONFIG_DIR=${HOME}/.kube
KIND_KUBECONFIG_FILE=${KIND_KUBECONFIG_DIR}/kind-kubernetes-clusters-${KIND_CLUSTER_NAME}.kubeconfig
KIND_KUBERNETES_ADMIN_USER=admin-user
KIND_NETWORK_NAME=kind
KIND_NODE_IMAGE=kindest/node:v1.31.0@sha256:53df588e04085fd41ae12de0c3fe4c72f7013bba32a20e7325357a1ac94ba865
KIND_REGISTRY_NAME=kind-registry
KIND_REGISTRY_PORT=5000
WINHOME=$(shell ./tools/scripts/get_win_home.sh)
# extract the local ip address to add host on $(CRI_ENGINE) enviroment
LOCAL_HOST_ADDR= $(shell ip route show | grep -Pom 1 '[0-9.]{7,15}')
# LOCAL_HOST_ADDR= $(shell ip route show | awk '{print $$9}' | xargs)


CRI_ENGINE=docker


# export KIND_EXPERIMENTAL_PROVIDER=podman
export KUBECONFIG=${KIND_KUBECONFIG_FILE}

.PHONY: kind-create-cluster kind-delete-cluster get-cluster-token deploy-k8s undeploy-k8s kube-linter ks
.SILENT: kind-create-cluster kind-delete-cluster get-cluster-token deploy-k8s undeploy-k8s kube-linter ks
.ONESHELL: kind-create-cluster kind-delete-cluster deploy-k8s undeploy-k8s ks

kind-create-cluster:
	(
		( kind get clusters | grep -q ${KIND_CLUSTER_NAME} ) && ( echo "Cluster ${KIND_CLUSTER_NAME} already exists" && exit 0; )
	) || (

		echo "Creating Kubernetes cluster.... 🏗️"

		if [ -f "${KIND_CREATE_CLUSTER_SCRIPT}" ]; then
			$(KIND_CREATE_CLUSTER_SCRIPT) ${KIND_NETWORK_NAME} ${KIND_CLUSTER_NAME} ${KIND_KUBECONFIG_DIR} ${KIND_KUBECONFIG_FILE} ${KIND_NODE_IMAGE} ${KIND_REGISTRY_NAME} ${KIND_REGISTRY_PORT} ${KIND_KUBERNETES_ADMIN_USER} ${KIND_HOST_MOUNT_PATH} $(CRI_ENGINE)
		else
			( echo "${KIND_CREATE_CLUSTER_SCRIPT} not Found!" && exit 1; )
		fi
	)

get-cluster-token:
# kubectl -n kubernetes-dashboard get secret $(kubectl -n kubernetes-dashboard get sa/admin-user -o jsonpath="{.secrets[0].name}") -o go-template="{{.data.token | base64decode}}"
	kubectl -n kubernetes-dashboard describe secret $$(kubectl -n kubernetes-dashboard get secret | grep admin-user | awk '{print $$1}') | grep token: | awk -F 'token:' '{print $$2}' | sed 's/ //g'

kind-delete-cluster:
	$(CRI_ENGINE) network disconnect "${KIND_NETWORK_NAME}" "${KIND_REGISTRY_NAME}"
	kind delete cluster --name ${KIND_CLUSTER_NAME}

deploy-observability-k8s:
	kubectl create ns observability
	kubectl apply -f kubernetes/13-open-telemetry-collector.yaml
	kubectl apply -f kubernetes/11-prometheus.yaml
	kubectl apply -f kubernetes/12-grafana.yaml
	kubectl apply -f kubernetes/14-jaeger-svc.yaml
	kubectl apply -f kubernetes/clusters/tms-dev/99-ingress.yaml

undeploy-observability-k8s:
	kubectl delete -f kubernetes/99-ingress.yaml
	kubectl delete -f kubernetes/13-open-telemetry-collector.yaml
	kubectl delete -f kubernetes/11-prometheus.yaml
	kubectl delete -f kubernetes/12-grafana.yaml
	kubectl delete -f kubernetes/14-jaeger-svc.yaml
	kubectl delete ns observability

# CI 🚀
run-pipe:
	go run ci/main.go

# K6 ##################
# IN_HAR=${PWD}/tests/k6/in/new-recording_121959.har
# OUT_SCRIPT=${PWD}/tests/k6/autogen.js

# har-to-k6:
# 	npx har-to-k6 ${IN_HAR} -o ${OUT_SCRIPT}

# smoke-test:
# 	$(CRI_ENGINE) run -v `pwd`:/opt \
# 	--add-host=${K6_API_HOSTNAME}:${LOCAL_HOST_ADDR} \
# 	-e API_HOSTNAME=${K6_API_HOSTNAME} \
# 	-e USER_NAME=msAppUser \
# 	-e USER_PWD=msAppUser \
# 	--rm \
# 	-t \
# 	-i ${K6_DOCKER_IMAGE_NAME} run /opt/tests/k6/smoke.js

# RabbitMQ
.PHONY: deploy-rabbit
deploy-rabbit:
  kubectl apply -f "https://github.com/rabbitmq/cluster-operator/releases/latest/download/cluster-operator.yml"
	helm upgrade --install rabbitmq kubernetes/helm/rabbit --set password="guest"
