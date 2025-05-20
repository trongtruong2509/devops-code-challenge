# Build stage
FROM node:23-alpine3.20 AS builder

# Set NODE_ENV
ENV NODE_ENV=production

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies with exact versions
RUN npm ci --only=production

# Copy source
COPY . .

# Production stage
FROM node:17-alpine

# Add non-root user and install wget and dumb-init
RUN addgroup -S appgroup && \
    adduser -S appuser -G appgroup && \
    apk add --no-cache wget dumb-init && \
    apk upgrade --no-cache && \
    rm -rf /var/cache/apk/*

# Set working directory and copy built files
WORKDIR /app
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/index.js ./
COPY --from=builder /app/config.js ./

# Install only production dependencies and set permissions
RUN npm ci --only=production && \
    npm cache clean --force && \
    chown -R appuser:appgroup /app && \
    chmod -R 555 /app

# Switch to non-root user
USER appuser

# Add healthcheck
HEALTHCHECK --interval=30s --timeout=3s \
    CMD wget --no-verbose --tries=1 --spider http://localhost:8080/health || exit 1

# Expose the port the app runs on
EXPOSE 8080

# Use dumb-init as entrypoint
ENTRYPOINT ["/usr/bin/dumb-init", "--"]

# Start the application
CMD ["npm", "start"]
