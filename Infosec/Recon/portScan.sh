#!/bin/bash

# Scan opened ports on target IP

# Usage:
# ./portScan.sh <ip-address>

if [ $1 ]; then
	ip_address=$1
	for port in $(seq 1 65535); do
		timeout 1 bash -c "echo '' > /dev/tcp/$ip_address/$port" 2>/dev/null && echo "[*] Port $port OPEN" &
	done; wait
else
	echo -e "\n [*] Usage: ./portScan.sh <ip-address>\n"
	exit 1
fi
