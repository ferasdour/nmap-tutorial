#!/bin/bash

# Default: block port 8080
iptables -F
iptables -A INPUT -p tcp --dport 8080 -j DROP

# Start knockd
knockd -D &

# Start the flag service
/bin/cat /flag.txt| nc -lkp 8080

