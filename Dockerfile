# Multi-stage Dockerfile for BLE-M3 Android Interceptor
# Provides ARM cross-compilation toolchains for both architectures

FROM ubuntu:24.04 AS builder

# Avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install base dependencies and ARM cross-compilers
RUN apt-get update && apt-get install -y \
    gcc-arm-linux-gnueabi \
    gcc-arm-linux-gnueabihf \
    build-essential \
    wget \
    xz-utils \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Set up working directory
WORKDIR /build

# Copy source files
COPY BLE-M3.c keycodes.h ./

# Default command - show available architectures
CMD ["sh", "-c", "echo 'BLE-M3 Build Container'; echo ''; echo 'Available compilers:'; arm-linux-gnueabi-gcc --version | head -1; arm-linux-gnueabihf-gcc --version | head -1; echo ''; echo 'Usage:'; echo '  docker run --rm -v $(pwd):/build blem3-builder make armv7'; echo '  docker run --rm -v $(pwd):/build blem3-builder make armhf'; echo '  docker run --rm -v $(pwd):/build blem3-builder make all'"]

# Build stage for ARMv7
FROM builder AS build-armv7
RUN mkdir -p /output && \
    arm-linux-gnueabi-gcc --static BLE-M3.c -o /output/BLE-M3-armv7

# Build stage for ARM hard-float
FROM builder AS build-armhf
RUN mkdir -p /output && \
    arm-linux-gnueabihf-gcc --static BLE-M3.c -o /output/BLE-M3-armhf

# Final stage - contains both binaries
FROM scratch AS binaries
COPY --from=build-armv7 /output/BLE-M3-armv7 /
COPY --from=build-armhf /output/BLE-M3-armhf /
