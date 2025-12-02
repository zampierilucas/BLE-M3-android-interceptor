# BLE-M3 Android Interceptor - Justfile
# https://github.com/casey/just

# Default recipe - show available recipes
default:
    @just --list

# Variables
output_dir := "build"

# Clean build artifacts
clean:
    @echo "Cleaning build artifacts..."
    rm -rf {{output_dir}}
    @echo "Clean complete!"

# === Build recipes ===

# Build Docker image with cross-compilers
build-image:
    @echo "Building Docker image with ARM cross-compilers..."
    docker compose build build

# Build ARMv7 using Docker
armv7:
    @echo "Building ARMv7 in Docker container..."
    docker compose run --rm build-armv7

# Build ARM hard-float using Docker
armhf:
    @echo "Building ARM hard-float in Docker container..."
    docker compose run --rm build-armhf

# Build all ARM architectures using Docker
all:
    @echo "Building all ARM architectures in Docker container..."
    docker compose run --rm build-all

# Build for local x86_64 (development/testing only)
dev:
    @echo "Building for local x86_64..."
    mkdir -p {{output_dir}}
    gcc --static BLE-M3.c -o {{output_dir}}/BLE-M3-x86_64
    @echo "Built: {{output_dir}}/BLE-M3-x86_64"
    @ls -lh {{output_dir}}/BLE-M3-x86_64

# Open interactive shell in Docker container
shell:
    @echo "Opening shell in Docker container..."
    docker compose run --rm shell

# Clean Docker images and containers
clean-docker:
    @echo "Cleaning Docker images and containers..."
    docker compose down --rmi all -v
    @echo "Docker cleanup complete!"
