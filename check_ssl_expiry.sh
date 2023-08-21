#!/bin/bash

domain="$1"
days_threshold="$2"

echo "Checking SSL expiry for domain: $domain"

# Extract certificate expiration date
expiry_date=$(echo | openssl s_client -servername $domain -connect $domain:443 2>/dev/null | openssl x509 -noout -enddate | cut -d'=' -f 2)
if [ -z "$expiry_date" ]; then
   echo "Failed to extract expiry date for $domain"
   exit 1
fi
echo "Expiry date extracted: $expiry_date"

# Calculate remaining days
expiry_unix=$(date -d "$expiry_date" +%s)
current_unix=$(date +%s)
remaining_seconds=$(( $expiry_unix - $current_unix ))
remaining_days=$(( $remaining_seconds / 86400 ))  # 86400 seconds in a day

echo "Current date: $(date)"
echo "Remaining seconds: $remaining_seconds"
echo "Remaining days: $remaining_days"

if [ $remaining_days -lt $days_threshold ]; then
   message="SSL Expiry Alert\n   * Domain : $domain\n   * Warning : The SSL certificate for $domain will expire in $remaining_days days."
   echo "Sending Slack alert for $domain"
   curl -X POST -H 'Content-type: application/json' --data "{\"text\":\"$message\"}" "$SLACK_WEBHOOK_URL"
fi

