# Simple usage with a mounted data directory:
# > docker build -t terra .
# > docker run -it -p 1317:1317 -p 26657:26657 -p 26656:26656 terra terrad start
FROM alpine:3.12

# Copy 
WORKDIR /root

ENV PATH /root/bin:$PATH

COPY terrad ./bin/

RUN terrad init localterra
