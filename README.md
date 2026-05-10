# ONNX Runtime Binaries

Pre-built ONNX Runtime shared libraries for Linux, compiled on GitHub Actions with multiple Execution Providers (EPs) and C library targets.

## Build Matrix

| EP | x86_64 glibc | aarch64 glibc | x86_64 musl | aarch64 musl |
|---|---|---|---|---|
| CPU | ✅ | ✅ | ✅ | ✅ |
| XNNPACK | ✅ | ✅ | ✅ | ✅ |
| OpenVINO | ✅ | ❌ | ❌ | ❌ |

*OpenVINO is only built for x86_64 glibc because Intel does not provide official ARM64 Linux or musl builds.*

## GitHub Actions Workflows

### Build All
`.github/workflows/build-all.yml` — Builds the entire matrix in parallel and automatically publishes a GitHub Release and Docker images.

**Automatic triggers:**
- Pushing a tag matching `v*` (e.g., `v1.21.0`) triggers the full build, release, and Docker publish pipeline.

**Manual inputs:**
- `version` — ONNX Runtime version tag (defaults to tag name on push)
- `is_debug` — Produce debug builds

### Build One
`.github/workflows/build-one.yml` — Dispatch a single build for a specific EP, architecture, and libc.

### Build (Reusable)
`.github/workflows/build.yml` — Reusable workflow called by the orchestrators above.

**Runner selection:**
- `ubuntu-24.04` for x86_64
- `ubuntu-24.04-arm` for aarch64

**Container images:**
- `debian:trixie-slim` for glibc builds
- `alpine:latest` for musl builds

## Local Build

Use the top-level `build.sh` script:

```bash
./build.sh -v v1.21.0 cpu x86_64 glibc
```

Usage:
```
./build.sh [options] <ep> <arch> <libc>

Arguments:
  ep    = cpu | openvino | xnnpack
  arch  = x86_64 | aarch64
  libc  = glibc | musl

Options:
  -v <version>  ONNX Runtime version (default: v1.21.0)
  -d            Debug build
  -g <step>     Start at step 0-6
```

The build is split into modular steps under `steps/`:
1. `00-environment.sh` — Set environment variables
2. `01-install.sh` — Install system dependencies
3. `02-checkout.sh` — Clone ONNX Runtime
4. `03-install-openvino.sh` — Install OpenVINO (OpenVINO EP only)
5. `04-build.sh` — Compile ONNX Runtime
6. `05-stage.sh` — Stage artifacts
7. `06-pack.sh` — Create tarball

## Artifact Layout

Each artifact is a tarball containing:

```
lib/
  libonnxruntime.so*
  libonnxruntime_providers_*.so*
include/
  onnxruntime_c_api.h
  onnxruntime_cxx_api.h
  ...
MANIFEST.json
```

OpenVINO artifacts also include the required OpenVINO runtime libraries.

## Docker Images

Every successful build is automatically published to the GitHub Container Registry (`ghcr.io`):

```
ghcr.io/devexzh/onnxruntime-images:<version>-<ep>-<libc>-<arch>
```

Examples:
```
ghcr.io/devexzh/onnxruntime-images:v1.21.0-cpu-glibc-x86_64
ghcr.io/devexzh/onnxruntime-images:v1.21.0-xnnpack-musl-aarch64
ghcr.io/devexzh/onnxruntime-images:v1.21.0-openvino-glibc-x86_64
```

A `latest-<ep>-<libc>-<arch>` tag is also updated on every release.

**Docker image layout:**
```
/opt/onnxruntime/
  lib/
  include/
  MANIFEST.json
```

## License

This repository is licensed under the MIT License. ONNX Runtime itself is licensed under the MIT License. OpenVINO is licensed under the Apache-2.0 License.
