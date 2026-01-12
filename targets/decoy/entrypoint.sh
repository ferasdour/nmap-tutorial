#!/bin/bash
set -euo pipefail

LOGFILE=/var/log/decoy.log
mkdir -p /var/log
: > "$LOGFILE"

# flush existing rules and allow established
iptables -F
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# allow only the chosen decoy IP to reach port 8080
iptables -A INPUT -p tcp --dport 8080 -s 172.22.0.2 -j ACCEPT

# drop everything else to 8080
iptables -A INPUT -p tcp --dport 8080 -j DROP

# Best-effort: stream kernel log lines containing the prefix into the file
( journalctl -kf 2>/dev/null | grep --line-buffered "FW_DECOY:" >> "$LOGFILE" ) &

[ -f /flag.txt ] || echo "FLAG{decoy}" > /flag.txt
exec socat TCP-LISTEN:8080,reuseaddr,fork SYSTEM:"cat /flag.txt"
