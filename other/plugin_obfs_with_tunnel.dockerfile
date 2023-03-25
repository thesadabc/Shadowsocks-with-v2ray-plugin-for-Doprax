FROM  shadowsocks/shadowsocks-libev

USER 0
EXPOSE 80

RUN \
    sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/'  /etc/apk/repositories \
    && apk update \
    && apk add --no-cache nginx git gcc autoconf make libtool automake zlib-dev openssl asciidoc xmlto libpcre32 libev-dev g++ linux-headers\
    && rm -rf /var/cache/apk/*  /usr/share/man /tmp/* \
    && wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O /usr/bin/cloudflared \
    && chmod a+x /usr/bin/cloudflared \
    && git clone https://github.com/shadowsocks/simple-obfs.git \
    && cd simple-obfs && git submodule update --init --recursive && ./autogen.sh && ./configure && make && make install

ENV METHOD="aes-256-gcm" \
    PASSWORD="password" \
    PORT=8388 \
    CF_TOKEN=""

RUN mkdir /run/nginx && echo -e '\
server { \
    listen 0.0.0.0:SS_PORT default_server; \
    location / { \
        proxy_http_version 1.1; \
        proxy_set_header Upgrade $http_upgrade; \
        proxy_set_header Connection upgrade; \
        proxy_pass http://127.0.0.1:8888; \
    } \
}' > /etc/nginx/conf.d/default.conf \
    &&  echo -e '\
sed -i "s/SS_PORT/$SS_PORT/" /etc/nginx/conf.d/default.conf && nginx \n\
cloudflared tunnel --protocol http2 --no-autoupdate run --token $CF_TOKEN & \n\
ss-server -s0.0.0.0 -p8888 "-k$SS_PASSWORD" "-m$SS_METHOD" --plugin obfs-server --plugin-opts "obfs=http;http-method=POST" & \n\
wait' > /start.sh 

CMD ["sh", "/start.sh"]
