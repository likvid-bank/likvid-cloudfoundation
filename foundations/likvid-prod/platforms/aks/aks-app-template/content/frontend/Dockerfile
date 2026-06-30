# Build
FROM node:24-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm install
RUN npm install -g @angular/cli
COPY . .
RUN ng build --configuration=production

# Host
FROM nginx:latest
COPY --from=build app/dist/my-angular-app/browser /usr/share/nginx/html
EXPOSE 80
