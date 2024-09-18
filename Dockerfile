# Stage 1: Build the Rust application
FROM rust:1.81 as builder

WORKDIR /usr/src/app

# Copy Cargo.toml and Cargo.lock
COPY Cargo.toml Cargo.lock ./

# Create a dummy main.rs to build dependencies
RUN mkdir src && echo "fn main() {}" > src/main.rs

# Build dependencies to cache them
RUN cargo build --release && rm -rf src

# Copy the source code
COPY . .

# Build the actual application
RUN cargo build --release

# Stage 2: Create a minimal runtime image
FROM gcr.io/distroless/cc

# Copy the compiled binary from the builder stage
COPY --from=builder /usr/src/app/target/release/k8s-custom-controller /k8s-custom-controller

# Run the binary
ENTRYPOINT ["/k8s-custom-controller"]
