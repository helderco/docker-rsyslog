FROM debian:jessie
MAINTAINER Helder Correia <me@heldercorreia.com>

RUN apt-get update && \
    apt-get install rsyslog --no-install-recommends -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY rsyslog.conf /etc/
COPY 20-user.conf /etc/rsyslog.d/

VOLUME /var/run/rsyslog/dev
EXPOSE 514

CMD ["rsyslogd", "-n"]
