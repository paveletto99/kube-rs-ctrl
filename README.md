# kubernetes custom controller and kind setups with observability

- kube-rs
- kind
- skaffold
-

```shell
cargo upgrade -i allow && cargo update
```

## Install metric server on kind

```shell
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

kubectl patch -n kube-system deployment metrics-server --type=json \
  -p '[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'
```
