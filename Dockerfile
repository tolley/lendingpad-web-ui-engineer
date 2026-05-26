# Use the official Node.js image
FROM node:16-alpine AS build-stage

# Set the working directory
WORKDIR /app

# Copy package files and install dependencies
COPY lendingpad/package*.json ./
RUN NODE_ENV=development npm i
RUN npm install --force

# Copy the rest of the application files
COPY . .

# Build the Vue.js application
RUN npm run build

# Use Nginx to serve the application
FROM nginx:alpine
COPY --from=build-stage /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf