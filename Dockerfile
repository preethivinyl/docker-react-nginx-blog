# Build environment
FROM node:20-alpine AS build

# Enable corepack for consistent yarn usage
RUN corepack enable

WORKDIR /app
COPY . .

# Add postcss resolution to fix export issues
RUN apk add --no-cache jq && \
    jq '. + {resolutions: {"postcss": "8.4.31"}}' package.json > tmp.json && \
    mv tmp.json package.json

# Install dependencies
RUN yarn install

# 👇 Fix the Webpack OpenSSL error by setting env var
ENV NODE_OPTIONS=--openssl-legacy-provider

# Build the app
RUN yarn build

# Production environment
FROM nginx:stable-alpine
COPY --from=build /app/build /usr/share/nginx/html
COPY --from=build /app/nginx/nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
