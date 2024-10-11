package main

import (
	"context"
	"fmt"
	"os"
	"os/signal"
	"syscall"
	"time"

	"dagger.io/dagger"
	log "github.com/sirupsen/logrus"
)

func main() {
	ctx := context.Background()

	// Initialize Dagger client
	client, err := dagger.Connect(ctx, dagger.WithLogOutput(os.Stdout))
	if err != nil {
		panic(err)
	}
	defer client.Close()

	// Define the repository (assuming the current directory)
	source := client.Host().Directory(".")
	// TODO : add config file for kind
	// Create Kind Cluster
	/*fmt.Println("Creating Kind cluster...")
	kindContainer := client.Container().
		// From("kindest/node:v1.31.0@sha256:53df588e04085fd41ae12de0c3fe4c72f7013bba32a20e7325357a1ac94ba865"). // Use appropriate Kind node image
		From("docker:cli").
		// WithExec(strings.Split("apt-get update", " ")).
		WithExec(strings.Split("apk add --update curl", " ")).
		// WithExec(strings.Split("curl -fsSL https://get.docker.com -o get-docker.sh", " ")).
		// WithExec(strings.Split("sh ./get-docker.sh --dry-run", " ")).
		WithExec(strings.Split(`curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.24.0/kind-linux-amd64`, " ")).
		WithExec(strings.Split("chmod +x ./kind", " ")).
		WithExec(strings.Split("mv ./kind /usr/local/bin/kind", " ")).
		WithExec([]string{"kind", "create", "cluster", "--name", "dagger-kind"})
		// Execute Kind cluster creation
	_, err = kindContainer.Stdout(ctx)
	if err != nil {
		fmt.Printf("Failed to create Kind cluster: %v\n", err)
		os.Exit(1)
	}

	fmt.Println("Kind cluster created successfully.")

	// Allow some time for the cluster to be ready
	time.Sleep(10 * time.Second)

	// After creating the Kind cluster, extract the kubeconfig and pass it to Tanka.

	*/
	// Path to kubeconfig
	//	kubeconfigPath := os.Getenv("KUBECONFIG")
	//	if kubeconfigPath == "" {
	kubeconfigPath := os.ExpandEnv("/root/.kube/config")
	//	}

	//	kubeConfig := kindContainer.File(kubeconfigPath)
	kubeConfig := client.Host().File("kind-kubernetes-clusters-cluster-dev01.kubeconfig")

	// Define a step to install Tanka (if not already available)
	// Alternatively, use a container image that has Tanka installed
	runner := client.Container().
		From("grafana/tanka:latest").
		WithMountedDirectory("/workspace", source).
		WithMountedFile(kubeconfigPath, kubeConfig).
		WithEnvVariable("TKA_CONFIG", "/workspace/tanka").
		WithExec([]string{"tk", "apply", "/workspace/tanka/environments/default"})
	// Execute the pipeline
	_, err = runner.Stdout(ctx)
	if err != nil {
		fmt.Printf("Failed to apply Tanka configuration: %v\n", err)
		os.Exit(1)
	}

	fmt.Println("Grafana Tanka configuration applied successfully.")

	// Verify Deployment (Optional)
	fmt.Println("Verifying deployment...")
	kubectlContainer := client.Container().
		From("bitnami/kubectl:latest").
		WithMountedDirectory("/workspace", source).
		WithMountedFile(kubeconfigPath, kubeConfig).
		WithEnvVariable("KUBECONFIG", "/workspace/kubeconfig").
		WithExec([]string{"kubectl", "get", "deployments", "nginx-deployment", "-o", "wide"})

	output, err := kubectlContainer.Stdout(ctx)
	if err != nil {
		fmt.Printf("Failed to verify deployment: %v\n", err)
		os.Exit(1)
	}
	fmt.Printf("Deployment Details:\n%s\n", output)

	// delete kind cluster
	// kindContainer.WithExec([]string{"kind", "delete", "cluster", "--name", "dagger-kind"})
	// gracefull shotdown
	n := 2 // Interval in seconds
	ticker := time.NewTicker(time.Duration(n) * time.Second)
	defer ticker.Stop()

	// Set up channel to listen for termination signals
	signals := make(chan os.Signal, 1)
	// Catch SIGTERM and SIGINT
	signal.Notify(signals, syscall.SIGTERM, syscall.SIGINT)

	for {
		select {
		case <-ticker.C:

		case sig := <-signals:
			log.Infof("🛑 Received signal: %s, stopping...\n", sig)
			return // Exit the program
		}
	}
}
