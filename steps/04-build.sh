#!/bin/bash -eux

SOURCE_DIR=${ONNXRUNTIME_SOURCE_DIR:-$PWD/onnxruntime}
EP=${ONNXRUNTIME_EP:?}
TARGET_ARCH=${ONNXRUNTIME_TARGET_ARCH:?}
IS_DEBUG=${ONNXRUNTIME_IS_DEBUG:-false}

cd "$SOURCE_DIR"

CONFIG="Release"
if [ "$IS_DEBUG" == "true" ]; then
  CONFIG="Debug"
fi

BUILD_ARGS=(
  --config "$CONFIG"
  --build_shared_lib
  --parallel
  --skip_tests
  --allow_running_as_root
)

# Architecture flags for cross-compilation (not needed for native builds)
# GitHub ARM runners are native ARM64, so no --arm64 flag needed

case "$EP" in
  cpu)
    ;;
  openvino)
    # Source OpenVINO environment if available
    if [ -f /opt/intel/openvino/setupvars.sh ]; then
      source /opt/intel/openvino/setupvars.sh
    fi
    BUILD_ARGS+=(--use_openvino CPU)
    ;;
  xnnpack)
    BUILD_ARGS+=(--use_xnnpack)
    ;;
  *)
    echo "Unknown EP: $EP"
    exit 1
    ;;
esac

./build.sh "${BUILD_ARGS[@]}"
