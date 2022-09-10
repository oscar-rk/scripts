#!/bin/bash

# Scan opened ports on target IP

# Usage:
# ./portScan.sh <ip-address>

# User exit handling
function ctrl_c(){
   echo -e "[!] Exiting script ...\n"   
   exit 1
}

# User exit catching
trap ctrl_c INT

# Args check
if [ "$#" -ne 1 ]; then
	echo -e "\n [!] Usage: $0 <ip-address>\n"
	exit 1
fi

for port in $(seq 1 65535); do
	timeout 1 bash -c "echo '' > /dev/tcp/$1/$port" 2>/dev/null && echo "[+] Port $port OPEN" &
done; wait
