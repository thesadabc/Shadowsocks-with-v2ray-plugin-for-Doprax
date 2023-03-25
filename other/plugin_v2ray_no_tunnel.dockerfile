FROM  shadowsocks/shadowsocks-libev

USER 0
EXPOSE 80

RUN wget 'https://github.com/shadowsocks/v2ray-plugin/releases/download/v1.3.2/v2ray-plugin-linux-amd64-v1.3.2.tar.gz' -O ./v2ray-plugin.tar.gz \
    && tar -xf ./v2ray-plugin.tar.gz -C /tmp && mv /tmp/v2ray-plugin_linux_amd64 /usr/bin/v2ray-plugin

ENV METHOD="aes-256-gcm" \
    PASSWORD="password"

RUN echo -e 'ss-server -s0.0.0.0 -p80 "-k$PASSWORD" "-m$METHOD" --plugin v2ray-plugin --plugin-opts server' > /start.sh

CMD ["sh", "/start.sh"]
