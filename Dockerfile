# Dockerfile for Hello World application
FROM nginx:alpine
COPY index.html /usr/share/nginx/html/index.html
