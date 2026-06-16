#!/bin/bash
set -euo pipefail

# ==============================================================================
# CONFIGURATION
# ==============================================================================

USERNAME="yorguin"
SCRATCH_BASE="${SCRATCH_BASE_OVERRIDE:-/scratch/${USERNAME}}"
DERIVATIVES_SRC="${SCRATCH_BASE}/derivatives"
DEST_BASE="${DEST_BASE_OVERRIDE:-/project/rrg-kjerbi/${USERNAME}}"

ARCHIVE_NAME="derivatives_yorguin.tar"
ARCHIVE_PATH="${DEST_BASE}/${ARCHIVE_NAME}"

# Logs and manifest go to project — scratch is full
LOG_DIR="${DEST_BASE}/archive_logs"

# ==============================================================================
# SETUP
# ==============================================================================

mkdir -p "${LOG_DIR}"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
MASTER_LOG="${LOG_DIR}/archive_${TIMESTAMP}.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "${MASTER_LOG}"
}

trap 'log "Job interrupted. Removing partial archive..."; rm -f "${ARCHIVE_PATH}"; exit 1' INT TERM

log "=== Archive job started: ${TIMESTAMP} ==="
log "Source:      ${DERIVATIVES_SRC}"
log "Destination: ${ARCHIVE_PATH}"
log "Log:         ${MASTER_LOG}"

# ==============================================================================
# PRE-FLIGHT
# ==============================================================================

if [ ! -d "${DERIVATIVES_SRC}" ]; then
    log "ERROR: Source not found: ${DERIVATIVES_SRC}"
    exit 1
fi

if [ ! -d "${DEST_BASE}" ]; then
    log "ERROR: ${DEST_BASE} is not accessible from this node."
    exit 1
fi

if [ -s "${ARCHIVE_PATH}" ]; then
    log "Archive already exists and is non-empty: ${ARCHIVE_PATH}. Exiting."
    exit 0
fi

# ==============================================================================
# MANIFEST
# ==============================================================================

MANIFEST="${LOG_DIR}/derivatives_${TIMESTAMP:0:8}_manifest.txt"
log "Generating manifest -> ${MANIFEST}"
find "${DERIVATIVES_SRC}" -type f | sort > "${MANIFEST}"
FILE_COUNT=$(wc -l < "${MANIFEST}")
log "Files: ${FILE_COUNT}"
log "Manifest: ${MANIFEST}"

# ==============================================================================
# ARCHIVE
# ==============================================================================

log "Starting tar. Progress logged every 5000 records."

tar -cf "${ARCHIVE_PATH}" \
    --checkpoint=5000 \
    --checkpoint-action=echo="[%T] %{%Y-%m-%d %H:%M:%S}t -- checkpoint #%u" \
    -C "${SCRATCH_BASE}" "derivatives" \
    >> "${MASTER_LOG}" 2>&1

TAR_EXIT=$?

if [ ${TAR_EXIT} -ne 0 ]; then
    log "ERROR: tar failed (exit ${TAR_EXIT})"
    log "Removing partial archive..."
    rm -f "${ARCHIVE_PATH}"
    exit 1
fi

# ==============================================================================
# VERIFY
# ==============================================================================

if [ ! -s "${ARCHIVE_PATH}" ]; then
    log "ERROR: Archive missing or empty at ${ARCHIVE_PATH}"
    exit 1
fi

ARCHIVE_SIZE=$(du -sh "${ARCHIVE_PATH}" 2>/dev/null | cut -f1)
log "============================================================"
log "SUCCESS"
log "Archive:  ${ARCHIVE_PATH}"
log "Size:     ${ARCHIVE_SIZE}"
log "Manifest: ${MANIFEST}"
log "============================================================"

exit 0
