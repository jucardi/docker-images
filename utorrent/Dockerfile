FROM debian:7-slim

RUN apt-get update
RUN apt-get install -y --fix-missing \
        curl \
        libcurl4-openssl-dev \
        openssl \
        libssl-dev \
        procps

RUN mkdir /utorrent
RUN curl -SL http://download-hr.utorrent.com/track/beta/endpoint/utserver/os/linux-x64-debian-7-0 | \
    tar vxz --strip-components 1 -C /utorrent && \
    touch /utorrent/utserver.log

RUN apt-get purge -y curl && \
    apt-get autoremove -y && \
    apt-get clean -y

COPY ./settings.conf ./utorrent/settings.conf
COPY ./entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
