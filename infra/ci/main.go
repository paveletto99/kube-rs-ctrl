// A generated module for Infra functions
//
// This module has been generated via dagger init and serves as a reference to
// basic module structure as you get started with Dagger.
//
// Two functions have been pre-created. You can modify, delete, or add to them,
// as needed. They demonstrate usage of arguments and return types using simple
// echo and grep commands. The functions can be called from the dagger CLI or
// from one of the SDKs.
//
// The first line in this comment block is a short description line and the
// rest is a long description with more detail on the module's purpose or usage,
// if appropriate. All modules should have a short description.

package main

import (
	"context"
	"dagger/infra/internal/dagger"
)

type Infra struct{}

// Returns a container that echoes whatever string argument is provided
func (m *Infra) Echo(stringArg string) *dagger.Container {
	return dag.Container().From("alpine:latest").WithExec([]string{"echo", stringArg})
}

// Returns lines that match a pattern in the files of the provided Directory
func (m *Infra) GrepDir(ctx context.Context, directoryArg *dagger.Directory, pattern string) (string, error) {
	return dag.Container().
		From("alpine:latest").
		WithMountedDirectory("/mnt", directoryArg).
		WithWorkdir("/mnt").
		WithExec([]string{"grep", "-R", pattern, "."}).
		Stdout(ctx)
}

// Build a ready-to-use development environment
func (m *Infra) BuildEnv(source *dagger.Directory) *dagger.Container {
	return dag.Container().
		From("hashicorp/terraform:1.10.5").
		WithMountedDirectory("/ws", source).
		WithWorkdir("/ws").
		WithExec([]string{"terraform", "init"})
}

func (m *Infra) Validate(ctx context.Context, source *dagger.Directory) (string, error) {
	return m.BuildEnv(source).
		WithExec([]string{"terraform", "validate"}).
		Stdout(ctx)
}

func (m *Infra) Plan(ctx context.Context, source *dagger.Directory) (string, error) {
	return m.BuildEnv(source).
		WithExec([]string{"terraform", "plan"}).
		Stdout(ctx)
}

func (m *Infra) Apply(ctx context.Context, source *dagger.Directory) (string, error) {
	return m.BuildEnv(source).
		WithExec([]string{"terraform", "apply", "-auto-approve"}).
		Stdout(ctx)
}
