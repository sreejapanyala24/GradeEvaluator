#!/usr/bin/env bash

set -euo pipefail


# Trap unexpected errors and exit safely

on_error() {
  local exit_code=$?
  log ERROR "Script failed with exit code $exit_code on line $LINENO"
  exit "$exit_code"
}
trap on_error ERR

#Trap Ctrl+C to exit gracefully

on_interrupt() {

  log INFO "Script stopped by user."
  exit 0
}
trap on_interrupt INT TERM

#Logging mechanism with levels

log() {
  local level="$1" msg="$2"
  local timestamp
  timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
  case "$level" in
    INFO)    echo "$timestamp [INFO]    $msg" | tee -a "$LOGFILE"    ;;
    SUCCESS) echo "$timestamp [SUCCESS] $msg" | tee -a "$LOGFILE"    ;;
    ERROR)   echo "$timestamp [ERROR]   $msg" | tee -a "$LOGFILE" >&2 ;;
    *)       echo "$timestamp [UNKNOWN] $msg" | tee -a "$LOGFILE"    ;;
  esac
}


#Print usage instructions
usage() {
  echo "Usage: $0 <directory> <age_in_days> <interval_seconds> <logfile>"
}


#validating Script inputs.

validate_inputs() {
  if [[ ! -d "$TARGET_DIR" ]] ; then
    log ERROR "Directory does not exist: $TARGET_DIR"
    exit 1
  fi
  if ! [[ "$AGE" =~ ^[0-9]+$ ]]; then
    log ERROR "Age must be a positive integer . Got $AGE"
    exit 1
  fi
  if ! [[ "$INTERVAL" =~ ^[0-9]+$ ]];then
    log ERROR "INTERVAL must be a positive integer . Got $INTERVAL"
    exit 1
  fi
  touch "$LOGFILE" 2>/dev/null || {
    log ERROR "Cannot write to log file :$LOGFILE"
    exit 1
  }
  log INFO "Input validation successful."
}

#Perform cleanup

cleanup() {
  log INFO "Starting cycle | dir = '$TARGET_DIR' threshold = ${AGE}d"

  local -a files
  mapfile -t files < <(find "$TARGET_DIR" -type f -mtime +"$AGE" 2>/dev/null)

  [[ ${#files[@]} -eq 0 ]] &&  { log INFO "No stale files found." ; return ;}

  local deleted=0 failed=0

  for f in "${files[@]}" ; do
    if rm -- "$f"  2>/dev/null; then
      ((deleted++)) || true ; log SUCCESS "Deleted: '$f'"
    else
      ((failed++)) || true; log ERROR "Failed to delete: '$f'"
    fi
  done

  log INFO "Done | deleted=$deleted failed=$failed total=${#files[@]}"
}


# run_scheduler - runs forever

run_scheduler() {
  while true; do
    cleanup
    log INFO "Sleeping for $INTERVAL seconds..."
    sleep "$INTERVAL"
  done
}



#Entry Point
main(){
  if [[ $# -ne 4 ]] ; then
    usage
    exit 1
  fi
  TARGET_DIR="$1"
  AGE="$2"
  INTERVAL="$3"
  LOGFILE="$4"

  validate_inputs
  run_scheduler

}


main "$@"