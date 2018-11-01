FROM debian:stable-slim

RUN apt-get update
RUN apt-get install -y \
        libcurl4-openssl-dev \
        libsqlite3-dev \
        git \
        wget \
        apt-transport-https \
        build-essential

RUN wget http://master.dl.sourceforge.net/project/d-apt/files/d-apt.list -O /etc/apt/sources.list.d/d-apt.list

RUN apt-get update && \
    apt-get -y --allow-unauthenticated install --reinstall d-apt-keyring && \
    apt-get update && \
    apt-get install -y \
        dmd-compiler \
        dub

WORKDIR /

RUN git clone https://github.com/skilion/onedrive.git

WORKDIR /onedrive

RUN make

FROM debian:stable-slim

RUN apt-get update
RUN apt-get install -y \
        libcurl4-openssl-dev \
        libsqlite3-dev \
        procps

COPY --from=0 /onedrive/onedrive /onedrive
COPY ./config /default-config
COPY ./entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]