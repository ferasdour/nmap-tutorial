#!/bin/bash
set -euo pipefail
iptables -F
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -p tcp --dport 8080 -j ACCEPT
iptables -A INPUT -p udp --dport 8081 -m u32 --u32 "28=0xDEADBEEF" -j ACCEPT
iptables -A INPUT -j DROP

exec socat UDP-LISTEN:8081,reuseaddr,fork SYSTEM:"cat /flag.txt" &
exec socat TCP-LISTEN:8080,reuseaddr,fork SYSTEM:"echo 'try port 8081'"