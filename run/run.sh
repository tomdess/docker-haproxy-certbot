docker run --name lb -d \
    -e CERT1=my-common-name.domain, my-alternate-name.domain \
    -e EMAIL=my.email@my.domain \
    -e STAGING=false \
    -v /srv/letsencrypt:/etc/letsencrypt \
    -v /srv/haproxycfg/haproxy.cfg:/etc/haproxy/haproxy.cfg \
    --network my_network \
    -p 80:80 -p 443:443 \
    ghcr.io/tomdess/docker-haproxy-certbot:master
