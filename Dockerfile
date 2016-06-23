FROM debian:jessie
MAINTAINER Helder Correia <helder@siriux.org>

RUN apt-get update && \
    apt-get install rsyslog --no-install-recommends -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY rsyslog.conf /etc/
COPY rsyslog.d/ /etc/rsyslog.d/

VOLUME /var/run/rsyslog/dev
EXPOSE 514/tcp 514/udp

CMD ["rsyslogd", "-n"]
