FROM alpine:latest

RUN apk update && apk add docker bash --no-cache

COPY ./entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]