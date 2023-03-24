#!/bin/bash

# Function to check if an IP address is valid
is_valid_ip_address() {
  local ip_address=$1
  local octets=$(echo $ip_address | tr '.' ' ')
  for octet in $octets; do
    if ! [[ "$octet" =~ ^[0-9]+$ ]] || (( $octet < 0 || $octet > 255 )); then
      return 1
    fi
  done
  return 0
}

# Function to get the public IP address from a source
get_ip_address() {
  local source=$1
  local ip_address=$(curl -s $source)
  if is_valid_ip_address "$ip_address"; then
    echo $ip_address
  else
    echo ""
  fi
}

# Get the current public IP address from multiple sources
IP_ADDRESSS=($(get_ip_address https://api.ipify.org) $(get_ip_address https://ifconfig.me) $(get_ip_address https://icanhazip.com) $(get_ip_address https://ipecho.net/plain))
IP_ADDRESS=""
if [[ " ${IP_ADDRESSS[@]} " =~ " $1 " ]]; then
    IP_ADDRESS=$1
else
    declare -A ip_count
    for ip in "${IP_ADDRESSS[@]}"; do
        [[ -z "$ip" ]] && continue
        ((ip_count[$ip]++))
    done
    max_count=0
    for ip in "${!ip_count[@]}"; do
        if ((ip_count[$ip] > max_count)); then
            max_count=${ip_count[$ip]}
            IP_ADDRESS=$ip
        fi
    done
fi

echo "$IP_ADDRESS"
