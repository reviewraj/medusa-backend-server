# syntax=docker/dockerfile:1

ARG NODE_VERSION=20.14.0

FROM node:${NODE_VERSION}-alpine

ENV NODE_ENV=production

# Install Git and other dependencies using apk (Alpine package manager)
RUN apk add --no-cache git && apk add postgresql-client

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json to leverage Docker's caching
COPY package*.json ./

# Install dependencies and Medusa CLI globally
RUN npm install && npm install -g @medusajs/medusa-cli@latest

# Copy the rest of the application code with proper ownership for the 'node' user
COPY  . .

# Expose the port the application will run on
EXPOSE 7001

CMD ["npx","medusa","develop"]
