#!/bin/bash

UPDATE_SCRIPT=./update-dns.sh
DB_FILE=./dns_updates.db
PUBLIC_IP_SCRIPT=./get-public-ip.sh


source name.com-config.sh

# Create the DNS updates table if it doesn't exist
sqlite3 "$DB_FILE" <<EOF
CREATE TABLE IF NOT EXISTS dns_updates (
  id INTEGER PRIMARY KEY,
  ip_address TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  result TEXT
);
EOF

# Get the current public IP address
IP_ADDRESS=$($PUBLIC_IP_SCRIPT)

CUR_DNS_IP=$(dig +short $HOSTNAME) 


# Check if the IP address has changed since the last run
LAST_IP=$(sqlite3 "$DB_FILE" "SELECT ip_address FROM dns_updates ORDER BY updated_at DESC LIMIT 1;")
if [ "$LAST_IP" = "$IP_ADDRESS" ] && [ "$IP_ADDRESS" = "$CUR_DNS_IP" ]
then
    echo "Public IP address has not changed"
else
    echo "Public IP address has changed to $IP_ADDRESS"

    # Store the new IP address and timestamp in the database
    TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
    sqlite3 "$DB_FILE" "INSERT INTO dns_updates (ip_address, updated_at) VALUES ('$IP_ADDRESS', '$TIMESTAMP');"

    # Run the update script and store the result in the database
    RESULT=$($UPDATE_SCRIPT $IP_ADDRESS)
    sqlite3 "$DB_FILE" "UPDATE dns_updates SET result = '$RESULT' WHERE updated_at = '$TIMESTAMP';"
fi
