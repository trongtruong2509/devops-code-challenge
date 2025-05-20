# Build stage
FROM node:14-alpine AS builder

WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .

# Build the application
RUN npm run build

# Production stage
FROM node:14-alpine

# Add non-root user and install wget and sed
RUN addgroup -S appgroup && \
    adduser -S appuser -G appgroup && \
    apk add --no-cache wget sed && \
    apk upgrade --no-cache && \
    rm -rf /var/cache/apk/*

# Set working directory and copy built files
WORKDIR /app
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/build ./build

# Create entrypoint script
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh && sed -i 's/\r$//' /docker-entrypoint.sh

# Install serve for static hosting and set permissions
RUN npm install -g serve && \
    npm cache clean --force && \
    chown -R appuser:appgroup /app

# Switch to non-root user
USER appuser

# Add healthcheck
HEALTHCHECK --interval=30s --timeout=3s \
    CMD wget --no-verbose --tries=1 --spider http://localhost:3000/ || exit 1

# Expose the port the app runs on
EXPOSE 3000

# Set the entrypoint script
ENTRYPOINT ["/docker-entrypoint.sh"]
