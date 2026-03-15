#!/bin/bash
# =============================================================================
# backup youtrack data to blob storage as youtrack recommend to use VM's OS Disk, VM is also backed up for max safety
# Syncs YouTrack backup archives (.tar.gz) to Azure Blob Storage
# Schedule: Daily at 6 AM via cron
# Cron:  0 6 * * * /path/to/yourscript.sh
# =============================================================================

# ── Configuration ─────────────────────────────────────────────────────────────
STORAGE_ACCOUNT="<your-storage-account-name>"
BLOB_CONTAINER="your-blob-container-name"
SAS_TOKEN="<your-sas-token>"
BLOB_URL="https://${STORAGE_ACCOUNT}.blob.core.windows.net/${BLOB_CONTAINER}"
BACKUP_DIR="/opt/youtrack/backups"
LOG_FILE="log-file-directory"
# ──────────────────────────────────────────────────────────────────────────────

echo "======================================" >> $LOG_FILE
echo "Sync started at $(date)" >> $LOG_FILE

# Sync only .tar.gz backup archives — no downtime, no container stop needed
# azcopy sync only uploads files that changed since the last run
azcopy sync "${BACKUP_DIR}/" \
  "${BLOB_URL}?${SAS_TOKEN}" \
  --recursive \
  --include-pattern="*.tar.gz" >> $LOG_FILE 2>&1

# Check if azcopy succeeded
if [ $? -eq 0 ]; then
  echo "Sync completed successfully at $(date)" >> $LOG_FILE
else
  echo "ERROR: Sync failed at $(date)" >> $LOG_FILE
fi

echo "======================================" >> $LOG_FILE