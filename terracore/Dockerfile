# Simple usage with a mounted data directory:
# > docker build -t terra .
# > docker run -it -p 26657:26657 -p 26656:26656 -v ~/.terrad:/root/.terrad -v ~/.terracli:/root/.terracli terra terrad init
# > docker run -it -p 26657:26657 -p 26656:26656 -v ~/.terrad:/root/.terrad -v ~/.terracli:/root/.terracli terra terrad start
FROM alpine:latest

RUN apk add build-base
RUN mkdir /lib64 && ln -s /lib/libc.musl-x86_64.so.1 /lib64/ld-linux-x86-64.so.2

# Copy 
WORKDIR /root

ENV PATH /root/bin:$PATH
ENV LD_LIBRARY_PATH /lib64

COPY terrad ./bin/
COPY terracli ./bin/
COPY libgo_cosmwasm.so /lib/

RUN terrad unsafe-reset-all
# Install tools & install core
# Intialize RUN make tools
#RUN cat $HOME/.terrad/config/config.toml
#RUN cat $HOME/.terrad/config/genesis.json

# Install libgo_cosmwasm.so to a shared directory where it is readable by all users
# See https://github.com/CosmWasm/wasmd/issues/43#issuecomment-608366314
# Note that CosmWasm gets turned into !cosm!wasm in the pkg/mod cache
#RUN cp /go/pkg/mod/github.com/\!cosm\!wasm/go-cosmwasm@v*/api/libgo_cosmwasm.so /lib/x86_64-linux-gnu
