#!/bin/bash -eux

VERSION=${ONNXRUNTIME_VERSION:-v1.21.0}
SOURCE_DIR=${ONNXRUNTIME_SOURCE_DIR:-$PWD/onnxruntime}

if [ ! -d "$SOURCE_DIR" ]; then
  git clone --recursive https://github.com/microsoft/onnxruntime.git "$SOURCE_DIR"
fi

cd "$SOURCE_DIR"
git fetch origin
git checkout "$VERSION"
git submodule update --init --recursive
