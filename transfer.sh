#!/usr/bin/env bash
#
# Wrapper around rclone for copy/sync jobs. Works against local paths
# and S3-compatible buckets, no rclone.conf needed - set RCLONE_S3_*
# env vars (or pass --s3-* flags) before calling this.
#
# Usage:
#   ./transfer.sh copy <source> <destination>
#   ./transfer.sh sync <source> <destination>
#
# Example:
#   ./transfer.sh copy ./source-dir ./dest-dir
#   ./transfer.sh sync ./source-dir :s3:my-bucket

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="${SCRIPT_DIR}/logs"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
LOG_FILE="${LOG_DIR}/transfer-${TIMESTAMP}.log"

MODE="${1:-}"
SRC="${2:-}"
DST="${3:-}"

usage() {
  echo "Usage: $0 <copy|sync> <source> <destination>" >&2
  echo "  copy - one-way copy, never deletes anything at the destination" >&2
  echo "  sync - makes destination match source exactly (can delete files!)" >&2
  exit 1
}

if [[ -z "$MODE" || -z "$SRC" || -z "$DST" ]]; then
  usage
fi

if [[ "$MODE" != "copy" && "$MODE" != "sync" ]]; then
  echo "Error: first argument must be 'copy' or 'sync', got '$MODE'" >&2
  usage
fi

if ! command -v rclone >/dev/null 2>&1; then
  echo "Error: rclone is not installed or not on PATH." >&2
  exit 1
fi

mkdir -p "$LOG_DIR"

# don't touch a config file on disk - stay config-free
export RCLONE_CONFIG=/dev/null

echo "Starting rclone ${MODE}: '${SRC}' -> '${DST}'"
echo "Logging to: ${LOG_FILE}"

if [[ "$MODE" == "sync" ]]; then
  echo "Dry-run first (sync can delete files)..."
  rclone sync "$SRC" "$DST" --dry-run -v --log-file="${LOG_FILE}.dryrun"
  echo "Dry-run log: ${LOG_FILE}.dryrun"
fi

rclone "$MODE" "$SRC" "$DST" \
  --progress \
  --stats=5s \
  --stats-one-line \
  --transfers=4 \
  --checkers=8 \
  --retries=3 \
  --low-level-retries=10 \
  --log-file="$LOG_FILE" \
  --log-level=INFO

EXIT_CODE=$?

if [[ $EXIT_CODE -ne 0 ]]; then
  echo "Transfer FAILED (exit code ${EXIT_CODE}). Check ${LOG_FILE} for details." >&2
  exit "$EXIT_CODE"
fi

echo "Transfer finished OK. Full log: ${LOG_FILE}"
exit 0
