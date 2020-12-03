FROM nikolaik/python-nodejs:python3.9-nodejs15-slim

WORKDIR /app

COPY . .
RUN npm ci

ENTRYPOINT ["npm", "run"]
