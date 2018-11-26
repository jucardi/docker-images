FROM bubuntux/nordvpn

RUN apk update
RUN apk add \
        curl \
        openssl \
        libssl \
        procps

RUN mkdir /utorrent
RUN curl -SL http://download-hr.utorrent.com/track/beta/endpoint/utserver/os/linux-x64-debian-7-0 | \
    tar vxz --strip-components 1 -C /utorrent && \
    touch /utorrent/utserver.log

COPY ./settings.conf ./utorrent/settings.conf
COPY ./entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]