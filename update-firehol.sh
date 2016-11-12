#!/bin/sh
# Assumptions:
# 1) firewall group named "FIREHOL_DROP" exists
# 2) A WAN_LOCAL / WAN_IN firewall rule is dropping the firehol group

group=FIREHOL_DROP
tmpgroup=fireholtmp

level1="https://raw.githubusercontent.com/firehol/blocklist-ipsets/master/firehol_level1.netset"

convert_blocklist() {
  curl $1 | grep '^[0-9]' | sed -e 's/;.*//' | sed -e "s/^/-A $tmpgroup /"
}

getnetblocks() {
  cat <<EOF
# Generated by ipset
-N $tmpgroup nethash --hashsize 1024 --probes 4 --resize 20
EOF
  convert_blocklist $level1 
}

echo "Starting update of firehol blocklists..."
logger "Starting update of firehol blocklists..."

echo "$(getnetblocks)" | sudo ipset -exist restore

echo "... swapping groups"
sudo ipset swap $tmpgroup $group

echo "... destroying tmp"
sudo ipset destroy $tmpgroup

echo "... update of firehol blocklists complete. New count=[ $(ipset -L $group | wc -l) ]"
logger "... update of firehol blocklists complete. New count=[ $(ipset -L $group | wc -l) ]"