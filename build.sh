#!/bin/bash -eu

EP_NAMES="cpu|openvino|xnnpack"
ARCH_NAMES="x86_64|aarch64"
LIBC_NAMES="glibc|musl"
STEP_REGEX="[0-9]|10"

START_STEP=0

if [[ $# == 0 ]]; then
  echo "ONNX Runtime build script.

Usage $0 [options] ep arch libc

Arguments:
   ep       = Execution provider ($EP_NAMES)
   arch     = Target architecture ($ARCH_NAMES)
   libc     = C library ($LIBC_NAMES)

Options:
  -v version = ONNX Runtime version (default=v1.21.0)
  -g 0-6    = Go immediately to step n (default=0)
  -d        = debug build"
  exit
fi

while getopts "v:dg:" OPTION; do
  case $OPTION in
    v)
      export ONNXRUNTIME_VERSION="$OPTARG"
      ;;
    d)
      export ONNXRUNTIME_IS_DEBUG=true
      ;;
    g)
      START_STEP="$OPTARG"
      ;;
    *)
      echo "Invalid flag -$OPTION"
      exit 1
      ;;
  esac
done
shift $(($OPTIND - 1))

if [[ $# -lt 3 ]]; then
  echo "You must specify EP, architecture, and libc"
  exit 1
fi

if [[ ! $1 =~ ^($EP_NAMES)$ ]]; then
  echo "Unknown EP: $1"
  exit 1
fi

if [[ ! $2 =~ ^($ARCH_NAMES)$ ]]; then
  echo "Unknown architecture: $2"
  exit 1
fi

if [[ ! $3 =~ ^($LIBC_NAMES)$ ]]; then
  echo "Unknown libc: $3"
  exit 1
fi

if [[ ! $START_STEP =~ ^($STEP_REGEX)$ ]]; then
  echo "Invalid step number: $START_STEP"
  exit 1
fi

export ONNXRUNTIME_EP=$1
export ONNXRUNTIME_TARGET_ARCH=$2
export ONNXRUNTIME_TARGET_LIBC=$3
export ONNXRUNTIME_VERSION=${ONNXRUNTIME_VERSION:-v1.21.0}
export ONNXRUNTIME_IS_DEBUG=${ONNXRUNTIME_IS_DEBUG:-false}

set -x

ENV_FILE=${GITHUB_ENV:-.env}

[ $START_STEP -le 0 ] && . steps/00-environment.sh
source "$ENV_FILE" 2>/dev/null || true

[ $START_STEP -le 1 ] && . steps/01-install.sh

[ $START_STEP -le 2 ] && . steps/02-checkout.sh

[ $START_STEP -le 3 ] && . steps/03-install-openvino.sh

[ $START_STEP -le 4 ] && . steps/04-build.sh

[ $START_STEP -le 5 ] && . steps/05-stage.sh

[ $START_STEP -le 6 ] && . steps/06-pack.sh
