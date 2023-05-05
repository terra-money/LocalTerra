ARG TERRA_VERSION=2.3.1

FROM ghcr.io/terra-money/core:${TERRA_VERSION}

COPY ./terra/genesis.json \
    ./terra/priv_validator_key.json \
    /app/config/

RUN mkdir -p /app/data && \
    echo '{"height": "0","round": 0,"step": 0}' > /app/data/priv_validator_state.json

CMD terrad start \
    --api.enable true \
    --api.enabled-unsafe-cors true \
    --api.swagger true \
    --home /app \
    --minimum-gas-prices 0.015uluna \
    --moniker localterra \
    --p2p.upnp true \
    --rpc.laddr tcp://0.0.0.0:26657