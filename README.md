# Dockerized HAProxy with Let's Encrypt automatic certificate renewal capabilities

This container provides a HAProxy 1.9 application with Let's Encrypt certificates
generated at startup, as well as renewed (if necessary) once a week.

## Usage

```
docker run --name lb -d \
    -e CERTS=my.domain,my.other.domain \
    -e EMAIL=my.email@my.domain \
    -v /srv/letsencrypt:/etc/letsencrypt \
    -v /srv/haproxycfg/haproxy.cfg:/etc/haproxy/haproxy.cfg \
    --network my_network \
    -p 80:80 -p 443:443 \
    tomdess/docker-haproxy-certbot
```


### Customizing Haproxy

You will almost certainly want to create an image `FROM` this image or
mount your `haproxy.cfg` at `/etc/haproxy/haproxy.cfg`.


    docker run [...] -v <override-conf-file>:/etc/haproxy/haproxy.cfg tomdess/docker-haproxy-letsencrypt

The haproxy configuration provided file comes with the "resolver docker" directive to permit DNS runt-time resolution on backend hosts

### Credits

Most of ideas taken from https://github.com/BradJonesLLC/docker-haproxy-letsencrypt
