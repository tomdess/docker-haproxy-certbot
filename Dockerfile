# start from debian 9 slim version
FROM debian:stretch-slim

# enable backport repo
RUN echo deb http://httpredir.debian.org/debian stretch-backports main | tee /etc/apt/sources.list.d/backports.list

RUN apt-get update && apt-get install --no-install-recommends -yqq \
    gnupg \
    apt-transport-https \
    cron \
    wget \
    ca-certificates \
    curl \
    procps \
    && apt-get install --no-install-recommends -yqq certbot -t stretch-backports \
    && apt-get install --no-install-recommends -yqq supervisor \
    && apt-get clean autoclean && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

# install haproxy 1.9 from official debian repos (https://haproxy.debian.net/)

RUN curl https://haproxy.debian.net/bernat.debian.org.gpg | apt-key add -
RUN echo deb http://haproxy.debian.net stretch-backports-1.9 main | tee /etc/apt/sources.list.d/haproxy.list

RUN apt-get update \
    && apt-get install -yqq haproxy=1.9.\* -t stretch-backports \
    && apt-get clean autoclean && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

# See https://github.com/janeczku/haproxy-acme-validation-plugin
COPY haproxy-acme-validation-plugin/acme-http01-webroot.lua /etc/haproxy
COPY haproxy-acme-validation-plugin/cert-renewal-haproxy.sh /

# install cron job and remove useless ones
COPY crontab.txt /var/crontab.txt
RUN crontab /var/crontab.txt && chmod 600 /etc/crontab \
    && rm -f /etc/cron.d/certbot \
    && rm -f /etc/cron.hourly/* \
    && rm -f /etc/cron.daily/* \
    && rm -f /etc/cron.weekly/* \
    && rm -f /etc/cron.monthly/*

COPY supervisord.conf /etc/supervisord.conf
COPY certs.sh /
COPY bootstrap.sh /

RUN mkdir /jail

EXPOSE 80 443

VOLUME /etc/letsencrypt

COPY haproxy.cfg /etc/haproxy/haproxy.cfg

ENTRYPOINT ["/bootstrap.sh"]
