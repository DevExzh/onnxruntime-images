#!/bin/bash -eux

ENV_FILE=${GITHUB_ENV:-.env}

# Input
cat >>"$ENV_FILE" <<END
ONNXRUNTIME_SOURCE_DIR=$PWD/onnxruntime
ONNXRUNTIME_BUILD_DIR=$PWD/onnxruntime/build/Linux
END
