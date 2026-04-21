#!/usr/bin/env bash   

set -euo pipefail

log() {
local level="$1"
local  msg="$2"
echo "$(date "+%Y-%m-%d %H:%M:%S") [$level] $msg" | tee -a "$LOG_FILE"
}

if [[ $# -ne 4 ]] ; then
	echo "Usage: $0 <directory> <days> <interval_seconds> <log_file>"
	exit 1 
fi

TARGET_DIR="$1"
DAYS="$2"
INTERVAL="$3"
LOG_FILE="$4"

if [[ ! -d "$TARGET_DIR" ]] ; then
	echo "ERROR: Directory "$TARGET_DIR" does not exist"
	exit 1
fi
if ! [[ "$DAYS" =~ ^[0-9]+$ ]] ; then
	echo "ERROR : Days must be a positive number"
	exit 1
fi
if ! [[ "$INTERVAL" =~ ^[0-9]+$ ]] ; then
	echo "ERROR : Interval must be a positive number"
	exit 1
fi

log "INFO" "Cleanup started for directory=$TARGET_DIR, days = $DAYS"

cleanup() {
	log "INFO" "Running cleanup cycle..."
	mapfile -t files < <(find "$TARGET_DIR" -type f -mtime +"$DAYS")
	if [[ ${#files[@]} -eq 0 ]] ; then
		log "INFO" "No files older than $DAYS days"
		return
	fi
	for f in  "${files[@]}" ;do
		if rm "$f" ; then
			log "SUCCESS" "Deleted: $f"
		else 
			log "ERROR" "Failed to delete: $f"
		fi
	done
}

while true; do
    cleanup
    sleep "$INTERVAL"
done
