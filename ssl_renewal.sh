#!/bin/bash

# Configuration
DOMAIN="yourdomain.com"           # Change to your domain
WEB_SERVER="nginx"                # 'nginx' or 'apache'
LOGFILE="/var/log/ssl_renewal.log"
RENEWAL_THRESHOLD_DAYS=30
EMAIL="your.email@example.com"   # Change to your email

# Function to check days until cert expiration
days_until_expiry() {
  expiry_date=$(openssl x509 -enddate -noout -in /etc/letsencrypt/live/$DOMAIN/fullchain.pem | cut -d= -f2)
  expiry_epoch=$(date -d "$expiry_date" +%s)
  now_epoch=$(date +%s)
  echo $(( (expiry_epoch - now_epoch) / 86400 ))
}

# Start log entry
echo "=== SSL Renewal check started at $(date) ===" >> "$LOGFILE"

if [ ! -f "/etc/letsencrypt/live/$DOMAIN/fullchain.pem" ]; then
  echo "❌ Certificate file not found for $DOMAIN" | tee -a "$LOGFILE"
  SUBJECT="SSL Renewal Failed for $DOMAIN"
  echo "Certificate file missing at /etc/letsencrypt/live/$DOMAIN/fullchain.pem" | mail -s "$SUBJECT" "$EMAIL"
  exit 1
fi

days_left=$(days_until_expiry)
echo "Days until certificate expiry: $days_left" | tee -a "$LOGFILE"

EMAIL_BODY="SSL Renewal Report for $DOMAIN\n\nDays until expiry: $days_left\n\n"

if [ "$days_left" -le "$RENEWAL_THRESHOLD_DAYS" ]; then
  echo "Certificate expires soon (<= $RENEWAL_THRESHOLD_DAYS days). Attempting renewal..." | tee -a "$LOGFILE"
  EMAIL_BODY+="Certificate expires soon (<= $RENEWAL_THRESHOLD_DAYS days). Attempting renewal...\n"

  certbot renew --quiet --agree-tos
  renew_status=$?

  if [ $renew_status -eq 0 ]; then
    echo "✅ Certificate renewed successfully." | tee -a "$LOGFILE"
    EMAIL_BODY+="✅ Certificate renewed successfully.\n"

    if [ "$WEB_SERVER" == "nginx" ]; then
      systemctl reload nginx
      echo "Reloaded nginx." | tee -a "$LOGFILE"
      EMAIL_BODY+="Reloaded nginx.\n"
    elif [ "$WEB_SERVER" == "apache" ]; then
      systemctl reload apache2
      echo "Reloaded apache." | tee -a "$LOGFILE"
      EMAIL_BODY+="Reloaded apache.\n"
    fi
  else
    echo "❌ Certificate renewal failed!" | tee -a "$LOGFILE"
    EMAIL_BODY+="❌ Certificate renewal failed!\n"
  fi
else
  echo "Certificate is valid for more than $RENEWAL_THRESHOLD_DAYS days. No action needed." | tee -a "$LOGFILE"
  EMAIL_BODY+="Certificate is valid for more than $RENEWAL_THRESHOLD_DAYS days. No action needed.\n"
fi

echo "=== SSL Renewal check finished at $(date) ===" >> "$LOGFILE"

# Send email with log summary
echo -e "$EMAIL_BODY" | mail -s "SSL Renewal Report for $DOMAIN" "$EMAIL"
