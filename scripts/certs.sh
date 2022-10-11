#!/usr/bin/env bash

if [ -n "$CERT1" ] || [ -n "$CERT" ]; then
    if [ "$STAGING" = true ]; then
        for certname in ${!CERT*}; do
            certbot certonly --no-self-upgrade -n --text --standalone \
            --preferred-challenges http-01 \
            --staging \
            -d "${!certname}" --keep --expand --agree-tos --email "$EMAIL" \
            || exit 2
        done
    else
        for certname in ${!CERT*}; do
          	certbot certonly --no-self-upgrade -n --text --standalone \
            --preferred-challenges http-01 \
            -d "${!certname}" --keep --expand --agree-tos --email "$EMAIL" \
            || exit 1
        done
    fi

    mkdir -p /etc/haproxy/certs
    for site in `ls -1 /etc/letsencrypt/live | grep -v ^README$`; do
        cat /etc/letsencrypt/live/$site/privkey.pem \
          /etc/letsencrypt/live/$site/fullchain.pem \
          | tee /etc/haproxy/certs/haproxy-"$site".pem >/dev/null
    done
fi

exit 0
