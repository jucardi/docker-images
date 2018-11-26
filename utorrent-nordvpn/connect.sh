#!/bin/bash

export URL_NORDVPN_API="https://api.nordvpn.com/server"
export URL_RECOMMENDED_SERVERS="https://nordvpn.com/wp-admin/admin-ajax.php?action=servers_recommendations"
export URL_OVPN_FILES="https://downloads.nordcdn.com/configs/archives/servers/ovpn.zip"
export MAX_LOAD=70

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

# Create auth_file
echo "$USER" > /auth 
echo "$PASS" >> /auth
chmod 0600 /auth

openvpn --config /profile.ovpn \
    --auth-user-pass /auth --auth-nocache \
    --script-security 2