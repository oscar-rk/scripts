#!/bin/bash

# Scan active hosts on network

# Usage:
# ./portScan.sh <network segment>

# User exit handling
function ctrl_c(){
   echo -e "[!] Exiting script ...\n"   
   exit 1
}

# User exit catching
trap ctrl_c INT

# Args check
if [ "$#" -ne 1 ]; then
   echo -e "[!] Usage: $0 <network segment> (Example $0 192.168.1\n"
   exit 1
fi

for i in $(seq 1 254); do
  timeout 1 bash -c "ping -c 1 $1.$i &>/dev/null" && echo "[+] Host $1.$i - ACTIVE" &
done; wait
