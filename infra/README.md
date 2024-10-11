```
go install github.com/google/ko@latest

```

```
export KO_DOCKER_REPO=localhost:5000
$Env:KO_DOCKER_REPO="localhost:5000"
ko build cmd/main.go

```

to run locally

```
docker run -p 8080:8080 $(ko build .)\
```

☸️☸️☸️ ko 🚀 Kind [doc](https://ko.build/features/k8s/)

run ko on kind

```
ko apply -f config/

```

delete deploy

```
ko delete -f config/

```

🐳 if docker file change

```
ko resolve -f deploy.yaml > release.yaml
```

TODO

You can also change the `KO_DATA_PATH` environment variable to change path from `/cmd/app/kodata` to other directory.

https://www.rabbitmq.com/tutorials/tutorial-four-go.html


docker run -d --net=kind --restart=always -p "127.0.0.1:5000:5000" --name "kind-registry" registry:2