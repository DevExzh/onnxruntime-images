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

case "$EP" in
  cpu)
    ;;
  openvino)
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

# Retry build up to 3 times to mitigate transient network failures
for i in 1 2 3; do
  echo "Build attempt $i..."
  if ./build.sh "${BUILD_ARGS[@]}"; then
    echo "Build succeeded on attempt $i"
    exit 0
  fi
  if [ "$i" -lt 3 ]; then
    echo "Build attempt $i failed, waiting 30s before retry..."
    sleep 30
  fi
done

echo "Build failed after 3 attempts"
exit 1
