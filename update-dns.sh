#!/bin/bash


source name.com-config.sh


# Maximum number of retries
MAX_RETRIES=5

# Retry interval in seconds
RETRY_INTERVAL=60

# Get the current public IP address
IP_ADDRESS=$1

is_valid_ip_address() {
  [[ -z "$1" ]] && return 1
  local ip_address=$1
  local octets=$(echo $ip_address | tr '.' ' ')
  for octet in $octets; do
    if ! [[ "$octet" =~ ^[0-9]+$ ]] || (( $octet < 0 || $octet > 255 )); then
      return 1
    fi
  done
  return 0
}


if ! is_valid_ip_address "$1"; then
  echo "Invalid IP specified. Please specify the new IP as the only argument."
  exit 1;
fi

# Loop to retry on failure
RETRY_COUNT=0
while [ $RETRY_COUNT -le $MAX_RETRIES ]
do
    # Get the record ID for the hostname
    RECORDS=$(curl -s -u "$API_USER:$API_KEY" "https://api.name.com/v4/domains/$DOMAIN/records?hostname=$HOSTNAME")
    RECORD_ID=$(echo $RECORDS | jq '.records[] | select(.host == "'$SUBDOMAIN'" and .type == "A") | .id')
    if [ -z "$RECORD_ID" ]
    then
        echo "Failed to find record ID for hostname $HOSTNAME"
        exit 1
    fi

    # Update the DNS record with the new IP address
    RESPONSE=$(curl -s -u "$API_USER:$API_KEY" -H "Content-Type: application/json" -X PUT -d "{\"type\": \"A\", \"answer\": \"$IP_ADDRESS\"}" "https://api.name.com/v4/domains/$DOMAIN/records/$RECORD_ID")
    if [[ $RESPONSE == *"Unauthorized"* ]]
    then
        echo "Failed to update DNS record: $RESPONSE"
        echo "Retrying in $RETRY_INTERVAL seconds (attempt $((RETRY_COUNT+1)) of $MAX_RETRIES)"
        sleep $RETRY_INTERVAL
        RETRY_COUNT=$((RETRY_COUNT+1))
        continue
    fi

    # Exit the loop on success
    echo "DNS record updated successfully with IP address $IP_ADDRESS"
    break
done

if [ $RETRY_COUNT -gt $MAX_RETRIES ]
then
    echo "Failed to update DNS record after $MAX_RETRIES attempts"
    exit 1
fi
