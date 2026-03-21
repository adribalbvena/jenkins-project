FROM node:20-alpine 

WORKDIR /app

RUN addgroup -S nodegroup && adduser -S nodeuser -G nodegroup

COPY app/package*.json ./
RUN npm ci --only=production

COPY app/ .

RUN chown -R nodeuser:nodegroup /app

USER nodeuser

EXPOSE 3000

CMD ["node", "server.js"]