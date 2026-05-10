#!/bin/bash -eux

TARGET_LIBC=${ONNXRUNTIME_TARGET_LIBC:?}
TARGET_ARCH=${ONNXRUNTIME_TARGET_ARCH:?}
EP=${ONNXRUNTIME_EP:?}

install_debian() {
  export DEBIAN_FRONTEND=noninteractive
  apt-get update
  apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    cmake \
    git \
    ninja-build \
    python3 \
    python3-pip \
    python3-venv \
    wget \
    curl \
    pkg-config

  if [ "$EP" == "openvino" ]; then
    apt-get install -y --no-install-recommends \
      libpugixml-dev \
      libtbb-dev
  fi
}

install_alpine() {
  apk add --no-cache \
    build-base \
    cmake \
    git \
    python3 \
    py3-pip \
    bash \
    wget \
    curl \
    pkgconfig \
    linux-headers
}

case "$TARGET_LIBC" in
  glibc)
    install_debian
    ;;
  musl)
    install_alpine
    ;;
  *)
    echo "Unknown libc: $TARGET_LIBC"
    exit 1
    ;;
esac
