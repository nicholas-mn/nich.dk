# Stage 1: Build Hugo site
FROM alpine:latest AS build

# Install Hugo and dependencies
RUN apk add --no-cache hugo git

# Set working directory
WORKDIR /site

# Copy site content
COPY . .

# Build the site
RUN hugo --minify

# Stage 2: Serve with Caddy
FROM caddy:alpine

# Copy built site to Caddy's web root
COPY --from=build /site/public /usr/share/caddy

# Copy Caddyfile
COPY Caddyfile /etc/caddy/Caddyfile

# Expose HTTP port
EXPOSE 80
