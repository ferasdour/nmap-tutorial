# Tutorial:
Gist of this is to showcase ways to test nmap to get around, exploit, or emphasize firewall rules. 

# Contributing:
Please feel free to pr, file an issue, whatever. A linux VM with docker should be able to run these correctly. 

Things I've already come across:
- in windows and linux docker hosts, these function differently.
- in windows and linux hosts, nmap functions differently for certain features.

Goals:
- Needs more test examples. (couldn't get just blocking all syn traffic to work, for example, inside a container)

# testing containers:
folder structure:
- targets
- - /test
  - - files for test


- [ ] /fw_decoy - 172.22.0.7
```
Doesn't work:
nmap -p 8080 -sS -Pn 172.22.0.7

Does work:
nmap -p 8080 -sS -Pn -D 172.22.0.2,ME 172.22.0.7
docker exec -it fw_basic_drop bash -c "tcpdump -n -i any 'tcp and host 172.22.0.7 and port 8080' -vv"


nmap -p 8080 -sS -Pn -D 172.22.0.2,ME 172.22.0.7
Starting Nmap 7.94SVN ( https://nmap.org ) at 2026-01-11 17:11 UTC
Nmap scan report for 172.22.0.7
Host is up (0.000065s latency).

PORT     STATE    SERVICE
8080/tcp filtered http-proxy
MAC Address: 1E:FA:7F:A7:BB:9E (Unknown)

Nmap done: 1 IP address (1 host up) scanned in 1.01 seconds

docker exec -it fw_basic_drop bash -c "tcpdump -n -i any 'tcp and host 172.22.0.7 and port 8080' -vvv"
tcpdump: data link type LINUX_SLL2
tcpdump: listening on any, link-type LINUX_SLL2 (Linux cooked v2), snapshot length 262144 bytes
    172.22.0.7.8080 > 172.22.0.2.55108: Flags [S.], cksum 0x5854 (incorrect -> 0xae8d), seq 4015847224, ack 1422550061, win 64240, options [mss 1460], length 0
17:10:40.329092 eth0  Out IP (tos 0x0, ttl 64, id 0, offset 0, flags [DF], proto TCP (6), length 40)
    172.22.0.2.55108 > 172.22.0.7.8080: Flags [R], cksum 0xa7de (correct), seq 1422550061, win 0, length 0
17:10:40.429220 eth0  In  IP (tos 0x0, ttl 64, id 0, offset 0, flags [DF], proto TCP (6), length 44)
    172.22.0.7.8080 > 172.22.0.2.55110: Flags [S.], cksum 0x5854 (incorrect -> 0xfca6), seq 1451049469, ack 1422418991, win 64240, options [mss 1460], length 0
17:10:40.429229 eth0  Out IP (tos 0x0, ttl 64, id 0, offset 0, flags [DF], proto TCP (6), length 40)
    172.22.0.2.55110 > 172.22.0.7.8080: Flags [R], cksum 0xa7dc (correct), seq 1422418991, win 0, length 0
17:11:40.830073 eth0  In  IP (tos 0x0, ttl 64, id 0, offset 0, flags [DF], proto TCP (6), length 44)

```
- [ ] /fw_synblock - 172.22.0.5
```
Doesn't work:
nmap -p 8080 --scanflags synack -Pn 172.22.0.5 --packet-trace

Does work:
nmap -p 8080 --scanflags syn -Pn 172.22.0.5 --packet-trace
```
- [ ] /fw_ttl - 172.22.0.6
```
Doesn't work:
nmap -p 8080 -sS -Pn 172.22.0.6
Does work:
nmap -p 8080 -sS --ttl 64 -Pn 172.22.0.6
```
- [ ] /fw_basic_drop - 172.22.0.2
```
Doesn't work:
nmap -p 8080,8081 -sS -Pn 172.22.0.2

Does work:
nmap -p 8080,8081 -sU -Pn 172.22.0.2 -m u32 --data "0xDEADBEEF" --packet-trace -vv
printf "\xDE\xAD\xBE\xEF" | socat - UDP:172.22.0.2:8081
```
- [ ] /fw_rate_limit - 172.22.0.8
```
Doesn't work:
nmap -p 8080 -sT -Pn 172.22.0.8

Does work (triggers rate limit):
for i in {1..20}; do nmap -p 8080 -sT -Pn 172.22.0.8|grep "8080/tcp filtered" & done|sort -u
8080/tcp filtered http-proxy

```
- [ ] /fw_knock - 172.22.0.4
```
Doesn't work:
nmap -sS -sV -p 8080 172.22.0.4

Does work:
knock 172.22.0.4 1111 2222 3333;  nmap -sSV -Pn -p 8080 172.22.0.4 --packet-trace

```
