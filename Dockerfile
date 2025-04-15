# Stage 1: Build Hugo site
FROM alpine:latest AS build

# Install dependencies (curl, git, unzip, and libc for Hugo)
RUN apk add --no-cache curl git unzip libc6-compat

# Set environment variables
ENV HUGO_VERSION=0.146.4

# Download and install Hugo
RUN curl -L https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_Linux-64bit.tar.gz \
    | tar -xz -C /usr/local/bin hugo

# Set working directory
WORKDIR /site

# Copy site content
COPY . .

# After copying the repo, before running Hugo
RUN git submodule update --init --recursive

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
