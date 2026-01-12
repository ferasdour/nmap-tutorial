#!/bin/bash
set -euo pipefail

iptables -F
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -p tcp --dport 8080 -m conntrack --ctstate NEW -m limit --limit 1/s --limit-burst 3 -j ACCEPT
iptables -A INPUT -p tcp --dport 8080 -m conntrack --ctstate NEW -j DROP

exec socat TCP-LISTEN:8080,reuseaddr,fork SYSTEM:"cat /flag.txt"
