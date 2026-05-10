#!/bin/bash -eux

TARGET_ARCH=${ONNXRUNTIME_TARGET_ARCH:?}
TARGET_LIBC=${ONNXRUNTIME_TARGET_LIBC:?}

if [ "$ONNXRUNTIME_EP" != "openvino" ]; then
  echo "Skipping OpenVINO installation (EP=$ONNXRUNTIME_EP)"
  exit 0
fi

if [ "$TARGET_LIBC" == "musl" ]; then
  echo "OpenVINO EP is not supported on musl builds"
  exit 1
fi

OPENVINO_VERSION=${OPENVINO_VERSION:-2025.4.0}
INSTALL_DIR=/opt/intel/openvino

# Map architecture to Intel naming
 case "$TARGET_ARCH" in
   x86_64)
     INTEL_ARCH="x86_64"
     ;;
   aarch64)
     INTEL_ARCH="arm64"
     ;;
   *)
     echo "Unsupported architecture for OpenVINO: $TARGET_ARCH"
     exit 1
     ;;
 esac

# Download and extract OpenVINO runtime
# Using the generic runtime archive
ARCHIVE="l_openvino_toolkit_ubuntu24_${OPENVINO_VERSION}_${INTEL_ARCH}.tgz"
URL="https://storage.openvinotoolkit.org/repositories/openvino/packages/${OPENVINO_VERSION%.*}/linux/${ARCHIVE}"

cd /tmp
wget -q "$URL" -O "$ARCHIVE" || {
  echo "Failed to download OpenVINO from $URL"
  exit 1
}

mkdir -p "$INSTALL_DIR"
tar -xzf "$ARCHIVE" -C "$INSTALL_DIR" --strip-components=1
rm -f "$ARCHIVE"

# Source environment
source "$INSTALL_DIR/setupvars.sh"

# Persist to GITHUB_ENV if available
ENV_FILE=${GITHUB_ENV:-.env}
cat >>"$ENV_FILE" <<END
OpenVINO_DIR=$INSTALL_DIR/runtime/cmake
LD_LIBRARY_PATH=$INSTALL_DIR/runtime/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}
PATH=$INSTALL_DIR/runtime/bin${PATH:+:$PATH}
END
