FROM node:lts

WORKDIR /app

COPY . .
RUN npm ci

ENTRYPOINT ["npm", "run"]
