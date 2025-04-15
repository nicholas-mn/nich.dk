# Stage 1: Build Hugo site
FROM alpine:latest AS build

# Install Hugo and dependencies from Alpine's package repo
RUN apk add --no-cache hugo git

# Set working directory
WORKDIR /site

# Copy site content
COPY . .

# Build the site
RUN hugo --minify

# Stage 2: Serve with Nginx
FROM nginx:alpine

# Copy built site to nginx's html dir
COPY --from=build /site/public /usr/share/nginx/html

# Expose port (optional)
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
