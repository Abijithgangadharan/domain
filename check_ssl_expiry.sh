#!/bin/bash

domain="$1"
days_threshold="$2"

expiry_date=$(openssl s_client -servername $domain -connect $domain:443 2>/dev/null | openssl x509 -noout -enddate | cut -d'=' -f 2)
expiry_unix=$(date -d "$expiry_date" +%s)
current_unix=$(date +%s)
remaining_days=$(( ($expiry_unix - $current_unix) / 86400 ))

if [ $remaining_days -lt $days_threshold ]; then
   message="SSL Expiry Alert\n   * Domain : $domain\n   * Warning : The SSL certificate for $domain will expire in $remaining_days days."
   curl -X POST -H 'Content-type: application/json' --data "{\"text\":\"$message\"}" $SLACK_WEBHOOK_URL
fi
