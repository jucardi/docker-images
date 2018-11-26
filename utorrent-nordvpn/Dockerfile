FROM jucardi/utorrent:latest

RUN apt-get update && \
    apt-get install -y bash curl unzip iptables openvpn python

ENV URL_NORDVPN_API="https://api.nordvpn.com/server" \
    URL_RECOMMENDED_SERVERS="https://nordvpn.com/wp-admin/admin-ajax.php?action=servers_recommendations" \
    URL_OVPN_FILES="https://downloads.nordcdn.com/configs/archives/servers/ovpn.zip" \
    MAX_LOAD=70 \
    PROFILE="us1879.nordvpn.com.tcp.ovpn"

COPY profiles/us1879.nordvpn.com.tcp.ovpn /profile.ovpn
COPY connect.sh /connect.sh
COPY bridge.sh /bridge.sh

ENTRYPOINT [ "/entrypoint.sh" ]