FROM node:10-alpine

# Create app directory
WORKDIR /usr/src/app

# Install app dependencies
COPY package*.json ./

RUN npm install

# Bundle app source
COPY public ./public
COPY server.js .

EXPOSE 3000

CMD [ "npm", "start" ]