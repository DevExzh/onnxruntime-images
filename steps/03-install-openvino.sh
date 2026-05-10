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
    LIB_DIR="intel64"
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

# Set environment manually instead of sourcing setupvars.sh
# (setupvars.sh has an unbound variable bug on some distributions)
ENV_FILE=${GITHUB_ENV:-.env}
cat >>"$ENV_FILE" <<END
OpenVINO_DIR=$INSTALL_DIR/runtime/cmake
LD_LIBRARY_PATH=$INSTALL_DIR/runtime/lib/$LIB_DIR:$INSTALL_DIR/runtime/3rdparty/tbb/lib:${LD_LIBRARY_PATH:-}
PATH=$INSTALL_DIR/runtime/bin/$LIB_DIR:${PATH:-}
END
