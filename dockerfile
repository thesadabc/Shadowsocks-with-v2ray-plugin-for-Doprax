# v2ray_plugin with cloudflare-tunnel
FROM  shadowsocks/shadowsocks-libev

USER 0
EXPOSE 80

RUN wget 'https://github.com/shadowsocks/v2ray-plugin/releases/download/v1.3.2/v2ray-plugin-linux-amd64-v1.3.2.tar.gz' -O ./v2ray-plugin.tar.gz \
    && tar -xf ./v2ray-plugin.tar.gz -C /tmp && mv /tmp/v2ray-plugin_linux_amd64 /usr/bin/v2ray-plugin \
    && wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O /usr/bin/cloudflared \
    && chmod a+x /usr/bin/cloudflared

ENV METHOD="aes-256-gcm" \
    PASSWORD="password" \
    PORT=8388 \
    CF_TOKEN=""

RUN echo -e 'cloudflared tunnel --protocol http2 --no-autoupdate run --token $CF_TOKEN & \n\
ss-server -s0.0.0.0 -p$PORT "-k$PASSWORD" "-m$METHOD" --plugin v2ray-plugin --plugin-opts server & \n\
wait' > /start.sh

CMD ["sh", "/start.sh"]
