#!/bin/bash
set -euo pipefail

iptables -F
iptables -A INPUT -p tcp --dport 8080 -m ttl --ttl-eq 64 -j ACCEPT
iptables -A INPUT -p tcp --dport 8080 -j DROP
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

[ -f /flag.txt ] || echo "FLAG{ttl64}" > /flag.txt
exec socat TCP-LISTEN:8080,reuseaddr,fork SYSTEM:"cat /flag.txt"
