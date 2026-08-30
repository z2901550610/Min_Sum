#!/usr/bin/env bash

# Source this file before using the repository's canonical local RTL workflow.
OSS_CAD_SUITE_ROOT="${OSS_CAD_SUITE_ROOT:-$HOME/tools/oss-cad-suite}"
EDA_REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"
if [[ -z "$EDA_REPO_ROOT" ]]; then
  echo "Source scripts/eda-env.sh from inside the repository" >&2
  return 1 2>/dev/null || exit 1
fi
PYTHON_VENV_ROOT="${PYTHON_VENV_ROOT:-$EDA_REPO_ROOT/.venv}"
HOST_PYTHON3="${HOST_PYTHON3:-$PYTHON_VENV_ROOT/bin/python3}"
HOST_COCOTB_CONFIG="${HOST_COCOTB_CONFIG:-$PYTHON_VENV_ROOT/bin/cocotb-config}"

if [[ ! -x "$HOST_PYTHON3" || ! -x "$HOST_COCOTB_CONFIG" ]]; then
  echo "Project Python environment not found: $PYTHON_VENV_ROOT" >&2
  echo "Run 'uv sync --frozen' from the repository root" >&2
  return 1 2>/dev/null || exit 1
fi

if [[ ! -f "$OSS_CAD_SUITE_ROOT/environment" ]]; then
  echo "OSS CAD Suite environment not found: $OSS_CAD_SUITE_ROOT/environment" >&2
  return 1 2>/dev/null || exit 1
fi

source "$OSS_CAD_SUITE_ROOT/environment"

PATH="$(dirname "$HOST_PYTHON3"):$(dirname "$HOST_COCOTB_CONFIG"):$PATH"
export PATH
export PYTHON_VENV_ROOT
export HOST_PYTHON3
export HOST_COCOTB_CONFIG
