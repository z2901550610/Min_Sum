#!/usr/bin/env bash

# Source this file before using the repository's canonical local RTL workflow.
OSS_CAD_SUITE_ROOT="${OSS_CAD_SUITE_ROOT:-$HOME/tools/oss-cad-suite}"
HOST_PYTHON3="${HOST_PYTHON3:-$(command -v python3)}"
HOST_COCOTB_CONFIG="${HOST_COCOTB_CONFIG:-$(command -v cocotb-config)}"

if [[ ! -f "$OSS_CAD_SUITE_ROOT/environment" ]]; then
  echo "OSS CAD Suite environment not found: $OSS_CAD_SUITE_ROOT/environment" >&2
  return 1 2>/dev/null || exit 1
fi

source "$OSS_CAD_SUITE_ROOT/environment"

PATH="$(dirname "$HOST_COCOTB_CONFIG"):$PATH"
export PATH
export HOST_PYTHON3
export HOST_COCOTB_CONFIG
