# rapidping

# This is a bash script that turns ping for Linux into a "rapid ping" like Cisco or Juniper.

# I'm doing this:
# 
# cp rapping.sh ~/.local/bin/rapping
# echo 'export PATH="$HOME/.local/bin:$HOME/bin:$PATH"' >> ~/.bashrc
# echo "alias ping=rapping">> ~/.bashrc
# sours ~/.bashrc
# 
# 
# dczi@toad[~]$ ping -s 1472 -r 10.205.5.250       
# PING 10.205.5.250 (10.205.5.250) 1472(1500) bytes of data.
# !!!!!
# --- 10.205.5.250 ping statistics ---
# 5 packets transmitted, 5 received, 0 packet loss, time 0ms
# rtt min/avg/max/mdev = 18.957/18.957/105.206/9.173 ms
# dczi@toad[~]$ ping -c 50 -s 1472 -r 10.237.149.64
# PING 10.205.5.250 (10.205.5.250) 1472(1500) bytes of data.
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!.!!!.!!!.!!!!!!!!!!!!
# --- 10.205.5.250 ping statistics ---
# 50 packets transmitted, 47 received, 3 packet loss, time 12000ms
# rtt min/avg/max/mdev = 18.957/18.957/272.241/49.023 ms
# dczi@toad[~]$ ping 10.237.149.64                 
# PING 10.237.149.64 (10.237.149.64) 56(84) bytes of data.
# 64 bytes from 10.237.149.64: icmp_seq=1 ttl=61 time=18.6 ms
# 64 bytes from 10.237.149.64: icmp_seq=2 ttl=61 time=59.4 ms
# 64 bytes from 10.237.149.64: icmp_seq=3 ttl=61 time=12.9 ms
# 64 bytes from 10.237.149.64: icmp_seq=4 ttl=61 time=12.9 ms
# ^C
# --- 10.237.149.64 ping statistics ---
# 4 packets transmitted, 4 received, 0% packet loss, time 4ms
# rtt min/avg/max/mdev = 12.907/25.965/59.419/19.453 ms

