FROM node:lts-slim

WORKDIR /app

COPY . .
RUN npm ci

ENTRYPOINT ["/usr/local/bin/npm", "run"]
