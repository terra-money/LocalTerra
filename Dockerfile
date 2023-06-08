ARG TERRA_VERSION=2.1.4

FROM ghcr.io/terra-money/core:${TERRA_VERSION}

# Set up fo nginx
USER root

COPY --chmod=644 nginx.conf /etc/nginx/nginx.conf
COPY --chmod=755 entrypoint.sh /usr/local/bin/entrypoint.sh

RUN apk add --no-cache nginx && \
    mkdir -p /var/lib/nginx/logs && \
    chown -R terra:terra /var/lib/nginx  && \
    ln -sf /dev/stdout /var/lib/nginx/logs/access.log && \
    ln -sf /dev/stderr /var/lib/nginx/logs/error.log

# Setup for localterra
COPY ./terra/genesis.json \
    ./terra/priv_validator_key.json \
    /app/config/

RUN chown -R terra:terra /app && \
    mkdir -p /app/data && \
    echo '{"height": "0","round": 0,"step": 0}' > /app/data/priv_validator_state.json

ENTRYPOINT [ "entrypoint.sh" ]

# rest server
EXPOSE 1317
# nginx
EXPOSE 8080
# grpc
EXPOSE 9090
# grpc-web
EXPOSE 9091
# tendermint p2p
EXPOSE 26656
# tendermint rpc
EXPOSE 26657

CMD terrad start \
    --home /app \
    --minimum-gas-prices 0.015uluna \
    --moniker localterra \
    --p2p.upnp true \
    --rpc.laddr tcp://0.0.0.0:26657 
    # --api.enable true \
    # --api.swagger true \
    # --api.enabled-unsafe-cors true 