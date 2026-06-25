#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

MODE="${MODE:-quick}"
PROFILE="${PROFILE:-bike128}"
THREADS="${THREADS:-0}"
SEED="${SEED:-1}"
OUT_DIR="${OUT_DIR:-}"

usage() {
  cat <<'EOF'
Usage: scripts/run_quantization_campaign.sh [options]

Options:
  --mode MODE         smoke, quick, or full (default: quick)
  --profile NAME      bike128, bike192, or bike256 (default: bike128)
  --threads N         worker count; 0 uses online CPUs (default: 0)
  --seed N            first deterministic seed (default: 1)
  --out-dir PATH      result directory
  --help              show this help

Environment variables MODE, PROFILE, THREADS, SEED, and OUT_DIR provide
the same settings.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --mode)
      MODE="$2"
      shift 2
      ;;
    --profile)
      PROFILE="$2"
      shift 2
      ;;
    --threads)
      THREADS="$2"
      shift 2
      ;;
    --seed)
      SEED="$2"
      shift 2
      ;;
    --out-dir)
      OUT_DIR="$2"
      shift 2
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

cd "${REPO_ROOT}"

command -v make >/dev/null 2>&1 || {
  echo "make is required" >&2
  exit 1
}
command -v python3 >/dev/null 2>&1 || {
  echo "python3 is required" >&2
  exit 1
}

echo "Building C model..."
make model-min-sum

CAMPAIGN_ARGS=(
  --model build/model/min_sum_model
  --mode "${MODE}"
  --profile "${PROFILE}"
  --threads "${THREADS}"
  --seed "${SEED}"
)

if [[ -n "${OUT_DIR}" ]]; then
  CAMPAIGN_ARGS+=(--out-dir "${OUT_DIR}")
fi

echo "Starting quantization campaign..."
exec python3 scripts/run_quantization_campaign.py "${CAMPAIGN_ARGS[@]}"
