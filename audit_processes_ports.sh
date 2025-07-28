#!/bin/bash

# === CONFIGURATION ===

LOGFILE="$HOME/audit_log.txt"
EMAIL="your.email@example.com"  # <-- Change this to your email

EXPECTED_PROCESSES=(
  "sshd"
  "bash"
  "systemd"
  "cron"
  "nginx"
  "apache2"
  "mysql"
  "mysqld"
)

EXPECTED_PORTS=(
  22
  80
  443
  3306
)

# === FUNCTIONS ===

log() {
  echo "$1" | tee -a "$LOGFILE"
}

send_alert_email() {
  SUBJECT="Alert: Unexpected processes or ports detected on $(hostname)"
  BODY=$(cat "$LOGFILE")
  echo "$BODY" | mail -s "$SUBJECT" "$EMAIL"
}

# === START AUDIT ===

echo "=== Audit started at $(date) ===" | tee "$LOGFILE"

# --- Check running processes ---

log "Checking running processes..."

CURRENT_PROCESSES=$(ps -eo comm= | sort -u)

log "Current running processes:"
echo "$CURRENT_PROCESSES" | tee -a "$LOGFILE"

unexpected_procs=()

while read -r proc; do
  match_found=false
  for allowed in "${EXPECTED_PROCESSES[@]}"; do
    if [[ "$proc" == *"$allowed"* ]]; then
      match_found=true
      break
    fi
  done
  if ! $match_found; then
    log "  - $proc"
    unexpected_procs+=("$proc")
  fi
done <<< "$CURRENT_PROCESSES"

# --- Check listening TCP ports ---

log ""
log "Checking open TCP ports..."

if command -v ss > /dev/null; then
  PORTS=$(ss -tln | awk 'NR>1 {split($4,a,":"); print a[length(a)]}' | sort -u)
elif command -v netstat > /dev/null; then
  PORTS=$(netstat -tln | awk 'NR>2 {split($4,a,":"); print a[length(a)]}' | sort -u)
else
  log "❌ Neither ss nor netstat found."
  exit 1
fi

log "Current listening TCP ports:"
echo "$PORTS" | tee -a "$LOGFILE"

unexpected_ports=()

while read -r port; do
  if [[ -z "$port" ]]; then
    continue
  fi
  if [[ ! " ${EXPECTED_PORTS[*]} " =~ " $port " ]]; then
    log "  - $port"
    unexpected_ports+=("$port")
  fi
done <<< "$PORTS"

log "=== Audit completed at $(date) ==="

# --- Send email alert if unexpected found ---
if [ ${#unexpected_procs[@]} -gt 0 ] || [ ${#unexpected_ports[@]} -gt 0 ]; then
  log "🚨 Unexpected processes or ports detected — sending alert email to $EMAIL"
  send_alert_email
else
  log "✅ No unexpected processes or ports found."
fi
