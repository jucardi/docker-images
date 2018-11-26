#!/bin/bash

# Firewall everything has to go through the vpn
iptables  -F OUTPUT
ip6tables -F OUTPUT 2> /dev/null
iptables  -P OUTPUT DROP
ip6tables -P OUTPUT DROP 2> /dev/null
iptables  -A OUTPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT 
ip6tables -A OUTPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT 2> /dev/null
iptables  -A OUTPUT -o lo -j ACCEPT
ip6tables -A OUTPUT -o lo -j ACCEPT 2> /dev/null
iptables  -A OUTPUT -o tun0 -j ACCEPT 
ip6tables -A OUTPUT -o tun0 -j ACCEPT 2> /dev/null
iptables  -A OUTPUT -d `ip -o addr show dev eth0 | awk '$3 == "inet" {print $4}'` -j ACCEPT
ip6tables -A OUTPUT -d `ip -o addr show dev eth0 | awk '$3 == "inet6" {print $4; exit}'` -j ACCEPT 2> /dev/null
iptables  -A OUTPUT -p udp --dport 53 -j ACCEPT
ip6tables -A OUTPUT -p udp --dport 53 -j ACCEPT 2> /dev/null
iptables  -A OUTPUT -o eth0 -p udp --dport 1194 -j ACCEPT 
ip6tables -A OUTPUT -o eth0 -p udp --dport 1194 -j ACCEPT 2> /dev/null
iptables  -A OUTPUT -o eth0 -p tcp --dport 1194 -j ACCEPT 
ip6tables -A OUTPUT -o eth0 -p tcp --dport 1194 -j ACCEPT 2> /dev/null

iptables_domain=`echo $URL_NORDVPN_API | awk -F/ '{print $3}'`
iptables  -A OUTPUT -o eth0 -d $iptables_domain -j ACCEPT
ip6tables -A OUTPUT -o eth0 -d $iptables_domain -j ACCEPT 2> /dev/null

if [ ! -z $NETWORK ]; then
    gw=`ip route | awk '/default/ {print $3}'`
    ip route add to $NETWORK via $gw dev eth0
    iptables -A OUTPUT --destination $NETWORK -j ACCEPT
fi

if [ ! -z $NETWORK6 ]; then
    gw=`ip -6 route | awk '/default/ {print $3}'`
    ip -6 route add to $NETWORK6 via $gw dev eth0
    ip6tables -A OUTPUT --destination $NETWORK6 -j ACCEPT 2> /dev/null
fi

# echo ${1-"10.8.0.0/24"}
# iptables -t nat -A POSTROUTING -s ${1-"10.8.0.0/24"} -o eth0 -j MASQUERADE
curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python -
