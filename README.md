# rsyslog

Docker image running rsyslog.


## How it works

I started off with [jpetazzo's syslogdocker](http://jpetazzo.github.io/2014/08/24/syslog-docker/), but didn't want to do the explicit host bind-mount to avoid sharing `/dev`. To solve that, I make rsyslog create the socket in `/var/run/rsyslog/dev/log` instead of the default location at `/dev/log`. This allows me to do `--volumes-from` without conflict, by making a symbolic link from `/dev/log` to the socket in the shared volume.

Another improvement is that I wanted to do `docker logs syslog` to see my logs, instead of a `docker exec -t syslog tail -f /var/log/syslog`. To do that, I've included an example configuration file that catches all priorities from `LEVEL1` facility and send them to *stderr*:

    # /etc/rsyslog.d/20-user.conf

    local1.*  {
        /proc/self/fd/2
        stop
    }


## How to use?

First, start the rsyslog container:

    docker run -d --name syslog helder/rsyslog

### 1. Symlink to /dev/log

If you must use `/dev/log`, you can start any container that you want to log to syslog with:

    docker run -it --rm --volumes-from syslog debian:jessie bash -c "ln -sf /var/run/rsyslog/dev/log /dev/log && logger -p local1.notice This is a notice!"

Obviously you'd create the symlink in the Dockerfile, or an entrypoint.

### 2. Use the custom socket location directly

If you can send your logs to any socket, then you don't need the symlink:

    docker run -it --rm --volumes-from syslog debian:jessie logger -u /var/run/rsyslog/dev/log -t myapp -p local1.error This is an error!

### 3. Use a remote tcp connection

If you can send your logs to a remote host, use port 514:

    docker run -it --rm --link syslog debian:jessie logger -n syslog -T -P 514 -p local1.error This is a remote error!

### 4. Use socat to connect local socket to remote host

Something like (not tested):

    socat UNIX-LISTEN:/dev/log,reuseaddr,fork TCP:syslog:514


## Add configuration

Just create your config files and in your Dockerfile, copy them to `/etc/rsyslog.d/`.


## Read logs

Assuming you're using `LEVEL1` priority, or added your own config to send logs to *stderr* or *stdout*, your logs can be seen with:

    docker logs -f syslog
