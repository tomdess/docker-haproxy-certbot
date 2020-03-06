docker run --name lb -d \
    -e CERTS=my.domain \
    -e EMAIL=my.mail \
    -v $PWD/data/letsencrypt:/etc/letsencrypt \
    -v $PWD/data/haproxy.cfg:/etc/haproxy/haproxy.cfg \
    --network web_network \
    -p 80:80 -p 443:443 \
    tomdess/haproxy-certbot:latest
