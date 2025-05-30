package main

import (
	"context"
	"fmt"
	"os"

	"dagger.io/dagger"
)

type TerraformDagger struct{}

// Build a ready-to-use development environment
func (m *TerraformDagger) BuildEnv(source *dagger.Directory) *dagger.Container {
	source = client.Host().Directory("~/myspace/kube-rs-ctrl/terraform")
	return dag.Container().
		From("hashicorp/terraform:1.10.5").
		WithDirectory("/ws", source).
		// WithMountedCache("/root/.npm", nodeCache).
		WithWorkdir("/ws").
		WithExec([]string{"terraform", "init"})
}

// func main() {
// 	ctx := context.Background()

// 	// Initialize Dagger client
// 	client, err := dagger.Connect(ctx, dagger.WithLogOutput(os.Stdout))
// 	if err != nil {
// 		panic(err)
// 	}
	// defer client.Close()

	// // Define the repository (assuming the current directory)
	// source := client.Host().Directory("~/myspace/kube-rs-ctrl/terraform")

	// // Define Terraform container
	// terraformContainer := client.Container().
	// 	From("hashicorp/terraform:1.10.5").
	// 	WithMountedDirectory("/ws", source)
	// WithEnvVariable("AWS_ACCESS_KEY_ID", os.Getenv("AWS_ACCESS_KEY_ID")).
	// WithEnvVariable("AWS_SECRET_ACCESS_KEY", os.Getenv("AWS_SECRET_ACCESS_KEY")).
	// WithEnvVariable("AWS_DEFAULT_REGION", "us-east-1").
	// WithEnvVariable("TF_VAR_bucket_name", "my-unique-bucket-name-12345"). // Replace with a unique bucket name

	// // Create or select a workspace
	// terraformWorkspace := terraformContainer.
	// 	WithExec([]string{"terraform", "workspace", "new", "dev"})

	// _, err = terraformWorkspace.Stdout(ctx)
	// if err != nil {
	// 	// Handle error or select existing workspace
	// 	fmt.Printf("Failed to create/select workspace: %v\n", err)
	// 	os.Exit(1)
	// }

	// Terraform Init
	// fmt.Println("Initializing Terraform...")
	// terraformInit := terraformContainer.
	// 	WithWorkdir("/ws").
	// 	WithExec([]string{"terraform", "init"})

	// _, err = terraformInit.Stdout(ctx)
	// if err != nil {
	// 	fmt.Printf("Terraform init failed: %v\n", err)
	// 	os.Exit(1)
	// }
	// fmt.Println("Terraform initialized successfully.")

	// Terraform Plan
	// fmt.Println("Planning Terraform deployment...")
	// terraformPlan := terraformInit.
	// 	WithExec([]string{"terraform", "plan", "-out=tfplan"})

	// trace, err := terraformPlan.Stdout(ctx)
	// fmt.Printf("Terraform plan trace: %s\n", trace)
	// if err != nil {
	// 	fmt.Printf("Terraform plan failed: %v\n", err)
	// 	os.Exit(1)
	// }
	// fmt.Println("Terraform plan completed successfully.")

	// // Terraform Apply
	// fmt.Println("Applying Terraform deployment...")
	// terraformApply := terraformContainer.
	// 	WithExec([]string{"terraform", "apply", "tfplan", "-out=tfplan"})

	// applyOutput, err := terraformApply.Stdout(ctx)
	// if err != nil {
	// 	fmt.Printf("Terraform apply failed: %v\n", err)
	// 	os.Exit(1)
	// }
	// fmt.Println("Terraform applied successfully.")
	// fmt.Println("Apply Output:")
	// fmt.Println(applyOutput)

	// // Retrieve Outputs (Optional)
	// fmt.Println("Retrieving Terraform outputs...")
	// terraformOutputs := terraformContainer.
	// 	WithExec([]string{"terraform", "output", "-json"})

	// outputs, err := terraformOutputs.Stdout(ctx)
	// if err != nil {
	// 	fmt.Printf("Failed to retrieve Terraform outputs: %v\n", err)
	// 	os.Exit(1)
	// }
	// fmt.Println("Terraform Outputs:")
	// fmt.Println(outputs)

	// fmt.Println("Dagger-Terraform pipeline completed successfully.")
}
