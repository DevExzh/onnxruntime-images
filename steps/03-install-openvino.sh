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

OPENVINO_VERSION=${OPENVINO_VERSION:-2025.4.0.0}
INSTALL_DIR=/opt/intel/openvino

case "$TARGET_ARCH" in
  x86_64)
    ARCHIVE="openvino_genai_ubuntu24_${OPENVINO_VERSION}_x86_64.tar.gz"
    ;;
  aarch64)
    ARCHIVE="openvino_genai_ubuntu20_${OPENVINO_VERSION}_arm64.tar.gz"
    ;;
  *)
    echo "Unsupported architecture for OpenVINO: $TARGET_ARCH"
    exit 1
    ;;
esac

URL="https://storage.openvinotoolkit.org/repositories/openvino_genai/packages/${OPENVINO_VERSION%.*.*}/linux/${ARCHIVE}"

cd /tmp
curl -L --fail "$URL" -o "$ARCHIVE" || {
  echo "Failed to download OpenVINO from $URL"
  exit 1
}

mkdir -p "$INSTALL_DIR"
tar -xzf "$ARCHIVE" -C "$INSTALL_DIR" --strip-components=1
rm -f "$ARCHIVE"

# Source environment
if [ -f "$INSTALL_DIR/setupvars.sh" ]; then
  source "$INSTALL_DIR/setupvars.sh"
fi

# Persist to GITHUB_ENV if available
ENV_FILE=${GITHUB_ENV:-.env}
cat >>"$ENV_FILE" <<END
OpenVINO_DIR=$INSTALL_DIR/runtime/cmake
LD_LIBRARY_PATH=$INSTALL_DIR/runtime/lib/intel64:$INSTALL_DIR/runtime/lib/aarch64:${LD_LIBRARY_PATH:-}
PATH=$INSTALL_DIR/runtime/bin/intel64:$INSTALL_DIR/runtime/bin/aarch64:${PATH:-}
END
