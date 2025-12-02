# Building BLE-M3

This document describes the build system for the BLE-M3 Android Interceptor project.

## Build Method

The project uses Docker/Podman for containerized builds with all dependencies included:
- Works on Linux, macOS, Windows (via WSL or native Docker)
- No need to install ARM cross-compilers on host system
- Most reliable and reproducible builds

## Using Docker/Podman

Docker provides a completely self-contained build environment that works on any platform.

### Prerequisites

Install Docker or Podman:
- **Docker**: [https://docs.docker.com/get-docker/](https://docs.docker.com/get-docker/)
  - Fedora: `sudo dnf install docker docker-compose`
  - Ubuntu: `sudo apt-get install docker.io docker-compose`
- **Podman**: [https://podman.io/getting-started/installation](https://podman.io/getting-started/installation)
  - Fedora: `sudo dnf install podman podman-compose`
  - Ubuntu: `sudo apt-get install podman podman-compose`

### Quick Start

```bash
# Using justfile (recommended)
just all                        # Build all ARM architectures
just armv7                      # Build ARMv7
just armhf                      # Build ARMHF
just dev                        # Build for local x86_64 (testing)
just shell                      # Interactive shell
just clean-docker               # Clean up containers

# Or using docker-compose directly
docker compose run --rm build-all
docker compose run --rm build-armv7
docker compose run --rm build-armhf
```

### Installing just (optional)

The justfile provides convenient shortcuts for Docker commands:

```bash
# Using cargo
cargo install just

# Fedora
sudo dnf install just

# Using homebrew (macOS/Linux)
brew install just
```

## Output Files

Binaries are placed in the `build/` directory (or custom output directory):

- `build/BLE-M3-armv7` - ARMv7 32-bit binary
- `build/BLE-M3-armhf` - ARM hard-float binary

## Architecture Details

### ARMv7 (arm-linux-gnu)
- 32-bit ARM architecture
- Soft-float ABI
- Compatible with older ARM devices
- Toolchain: arm-linux-gnu-gcc (Fedora: gcc-arm-linux-gnu package)

### ARM hard-float (arm-none-linux-gnueabihf)
- 32-bit ARM with hard-float
- Better floating-point performance
- Used in GitHub Actions CI
- Toolchain: arm-none-linux-gnueabihf-gcc

## Troubleshooting

### Docker build fails

Common issues:
- Docker daemon not running: Start Docker service
- Permission denied: Add user to docker group or use sudo
- Network issues: Ensure Docker can access the internet (project uses host networking)

## CI/CD

The GitHub Actions workflow automatically builds the ARM hard-float version on:
- Pushes to master branch
- Version tags (v*)
- Pull requests to master

See `.github/workflows/main.yaml` for CI configuration.

## Cross-Compilation Notes

The project uses static linking (`--static` flag) to:
- Eliminate runtime dependencies
- Ensure binary works on target Android devices
- Simplify deployment (single binary file)

## Examples

```bash
# Build all ARM architectures for Android
just all

# Build specific ARM architecture
just armv7

# Build for local development/testing (x86_64)
just dev

# Clean build artifacts
just clean
```

## Additional Resources

- [ARM GNU Toolchain Documentation](https://developer.arm.com/Tools%20and%20Software/GNU%20Toolchain)
- [Android ADB Documentation](https://developer.android.com/studio/command-line/adb)
- [Linux Cross-Compilation Guide](https://www.kernel.org/doc/html/latest/kbuild/llvm.html)
