#!/bin/bash
set -euo pipefail

iptables -F
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
# Accept if MSS (tcp-option 2)
iptables -A INPUT -p tcp --dport 8080 --tcp-option 2 -m conntrack --ctstate NEW -j ACCEPT
# Accept if Timestamp (tcp-option 8)
iptables -A INPUT -p tcp --dport 8080 --tcp-option 8 -m conntrack --ctstate NEW -j ACCEPT
# Drop other NEW SYNs to 8080
iptables -A INPUT -p tcp --dport 8080 -m conntrack --ctstate NEW -j DROP
nft add table inet filter
nft 'add chain inet filter input { type filter hook input priority 0; policy accept; }'
nft add rule inet filter input ct state established,related accept

[ -f /flag.txt ] || echo "FLAG{synblock}" > /flag.txt
exec socat TCP-LISTEN:8080,reuseaddr,fork SYSTEM:"cat /flag.txt"
