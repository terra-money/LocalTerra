ARG TERRA_VERSION=1.1.0

FROM ghcr.io/terra-money/core:${TERRA_VERSION}

# Set up fo nginx
USER root

COPY --chmod=644 nginx.conf /etc/nginx/nginx.conf
COPY --chmod=755 entrypoint.sh /usr/local/bin/entrypoint.sh

RUN apk add --no-cache nginx && \
    adduser -D -g www www \
    mkdir -p www \
    chown -R www:www /var/lib/nginx \
    chown -R www:www /www

# Setup for localterra
USER terra

COPY ./terra/genesis.json \
    ./terra/priv_validator_key.json \
    /app/config/

RUN mkdir -p /app/data && \
    echo '{"height": "0","round": 0,"step": 0}' > /app/data/priv_validator_state.json

ENTRYPOINT [ "entrypoint.sh" ]

CMD terrad start \
    --api.enable true \
    --api.enabled-unsafe-cors true \
    --api.swagger true \
    --home /app \
    --minimum-gas-prices 0.015uluna \
    --moniker localterra \
    --p2p.upnp true \
    --rpc.laddr tcp://0.0.0.0:26657