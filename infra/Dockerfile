#-------------- Build ----------
FROM golang:1.22-bookworm@sha256:5c56bd47228dd572d8a82971cf1f946cd8bb1862a8ec6dc9f3d387cc94136976 AS build

WORKDIR ko-kind-service

# copy code from local dir to container
COPY . ./

RUN CGO_ENABLED=0 go build -o /ko-kind-service cmd/main.go

#-------------- Deploy ----------
FROM gcr.io/distroless/static-debian12

WORKDIR /

#copy build image
COPY --from=build /ko-kind-service /ko-kind-service

COPY ./static ./static

EXPOSE 9200

USER nonroot:nonroot

ENTRYPOINT ["/ko-kind-service"]
