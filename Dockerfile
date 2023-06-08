ARG TERRA_VERSION=2.3.1

FROM ghcr.io/terra-money/core:${TERRA_VERSION}

RUN apk update && apk add supervisor nginx

COPY ./terra/genesis.json \
    ./terra/priv_validator_key.json \
    /app/config/

RUN mkdir -p /app/data && \
    echo '{"height": "0","round": 0,"step": 0}' > /app/data/priv_validator_state.json

COPY supervisord.conf /etc/supervisord.conf
COPY nginx.conf /etc/nginx/nginx.conf

ENTRYPOINT ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]