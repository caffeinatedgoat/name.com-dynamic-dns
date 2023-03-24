#!/bin/bash

# Path to the SQLite database
DB_FILE="./dns_updates.db"

# Print the DNS update history as a table
sqlite3 -header -column "$DB_FILE" "SELECT updated_at AS 'Timestamp', ip_address AS 'IP Address', result AS 'Result' FROM dns_updates;"

