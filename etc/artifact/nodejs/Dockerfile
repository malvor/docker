ARG NODE_VERSION=12

FROM node:${NODE_VERSION}-alpine AS nodejs

COPY artifact/nodejs/docker-entrypoint.sh /usr/local/bin/docker-entrypoint
RUN chmod +x /usr/local/bin/docker-entrypoint

WORKDIR /app
RUN npm install --global gulp-cli gulp
RUN npm install

ENTRYPOINT ["docker-entrypoint"]
CMD ["yarn", "watch"]
