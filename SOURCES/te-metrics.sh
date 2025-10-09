#!/usr/bin/env bash
# monitor-128t-config.sh
# - Watches 128T-mist-agent events and samples multiple pcli stats until healthy.
#
SERVICE='128T-mist-agent'
OUTDIR="/var/log/128technology"
CONFIG_SIG='config fetcher notified of cloud config change'
HEALTHY_SIG='health: status=healthy'

mkdir -p "$OUTDIR" || { echo "ERROR: cannot create $OUTDIR"; exit 1; }

while true; do
  # 1) Wait for the config-change trigger
  journalctl -fu "$SERVICE" \
    | grep --line-buffered -m1 -F "$CONFIG_SIG"

  echo "$(date +'%Y-%m-%d %H:%M:%S') [INFO] Detected CONFIG CHANGE. Starting sampling..."

  TIMESTAMP=$(date +'%Y%m%d_%H%M%S')
  LOGFILE="${OUTDIR}/${TIMESTAMP}_TE_metrics_output.log"
  echo "=== Starting capture at $(date) ===" >"$LOGFILE"

  # 2) Launch the sampler in background
  (
    while true; do
      TS=$(date +'%H:%M:%S')
      echo "--- $TS ---" >>"$LOGFILE"

      # Command 1
      pcli show stats traffic-eng internal-application node all since 1m \
        | egrep 'Service Area' | egrep 'exceeded|failure|timeout' >>"$LOGFILE" 2>&1

      # Command 2
      pcli show stats app-id since 1m >>"$LOGFILE" 2>&1

      # Command 3
      pcli show stats service-area received since 1m \
        | egrep 'adaptive|classification-update|dropped-packet|duplicate-reverse|mid-flow-modif' >>"$LOGFILE" 2>&1

      # Command 4
      pcli show stats aggregate-session by-node node all \
        | grep session >>"$LOGFILE" 2>&1
  
      # Insert two blank lines between cycles
      echo >>"$LOGFILE"
      echo >>"$LOGFILE"

      sleep 7
    done
  ) &
  SAMPLER_PID=$!

  # 3) In parallel, block until the next healthy marker
  journalctl -fu "$SERVICE" \
    | grep --line-buffered -m1 -F "$HEALTHY_SIG"

  # 4) Stop the sampler
  echo "$(date +'%Y-%m-%d %H:%M:%S') [INFO] Detected HEALTHY. Stopping sampler (PID $SAMPLER_PID)."
  kill "$SAMPLER_PID"
  wait "$SAMPLER_PID" 2>/dev/null

  # 5) Upload & rotate
  echo "$(date +'%Y-%m-%d %H:%M:%S') [INFO] Uploading $LOGFILE to cloud..."
  /usr/libexec/128T-mist-agent upload-file --skip-cleanup --path "$LOGFILE" \
    && echo "$(date +'%Y-%m-%d %H:%M:%S') [INFO] Upload succeeded." \
    || echo "$(date +'%Y-%m-%d %H:%M:%S') [ERROR] Upload failed." >&2

  echo "$(date +'%Y-%m-%d %H:%M:%S') [INFO] Cycle complete. Awaiting next config change."
done