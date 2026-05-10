#!/bin/bash -eux

SOURCE_DIR=${ONNXRUNTIME_SOURCE_DIR:-$PWD/onnxruntime}
STAGING_DIR=${ONNXRUNTIME_STAGING_DIR:-$PWD/staging}
EP=${ONNXRUNTIME_EP:?}
TARGET_ARCH=${ONNXRUNTIME_TARGET_ARCH:?}
TARGET_LIBC=${ONNXRUNTIME_TARGET_LIBC:?}
IS_DEBUG=${ONNXRUNTIME_IS_DEBUG:-false}

CONFIG="Release"
if [ "$IS_DEBUG" == "true" ]; then
  CONFIG="Debug"
fi

BUILD_OUTPUT="$SOURCE_DIR/build/Linux/$CONFIG"

mkdir -p "$STAGING_DIR/lib"
mkdir -p "$STAGING_DIR/include"
mkdir -p "$STAGING_DIR/bin"

# Copy shared libraries
cp "$BUILD_OUTPUT"/libonnxruntime.so* "$STAGING_DIR/lib/" 2>/dev/null || true
cp "$BUILD_OUTPUT"/libonnxruntime_providers_*.so* "$STAGING_DIR/lib/" 2>/dev/null || true

# Copy headers
cp -r "$SOURCE_DIR"/include/onnxruntime/core/session/* "$STAGING_DIR/include/" 2>/dev/null || true
cp -r "$SOURCE_DIR"/include/onnxruntime/core/providers/* "$STAGING_DIR/include/" 2>/dev/null || true

# If OpenVINO EP is used, also stage OpenVINO runtime libraries
if [ "$EP" == "openvino" ] && [ -d /opt/intel/openvino/runtime/lib ]; then
  cp /opt/intel/openvino/runtime/lib/libopenvino.so* "$STAGING_DIR/lib/" 2>/dev/null || true
  cp /opt/intel/openvino/runtime/lib/libopenvino_*.so* "$STAGING_DIR/lib/" 2>/dev/null || true
  cp -r /opt/intel/openvino/runtime/lib/intel64 "$STAGING_DIR/lib/" 2>/dev/null || true
  cp -r /opt/intel/openvino/runtime/lib/aarch64 "$STAGING_DIR/lib/" 2>/dev/null || true
fi

# Write manifest
cat > "$STAGING_DIR/MANIFEST.json" <<EOF
{
  "name": "onnxruntime",
  "ep": "$EP",
  "target_arch": "$TARGET_ARCH",
  "target_libc": "$TARGET_LIBC",
  "config": "$CONFIG",
  "version": "${ONNXRUNTIME_VERSION:-unknown}"
}
EOF
