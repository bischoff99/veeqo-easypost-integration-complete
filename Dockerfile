# Use official Node.js runtime as base image
FROM node:18-alpine

# Set working directory in container
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production && npm cache clean --force

# Copy TypeScript configuration
COPY tsconfig.json ./

# Copy source code
COPY src/ ./src/

# Build the application
RUN npm run build

# Create logs directory
RUN mkdir -p /app/logs

# Create non-root user for security
RUN addgroup -g 1001 -S nodejs && \
    adduser -S integration -u 1001 && \
    chown -R integration:nodejs /app

# Switch to non-root user
USER integration

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1

# Start the application
CMD ["node", "dist/index.js"]

# Metadata
LABEL maintainer="bischoff99 <t82k2cfs9d@proton.me>"
LABEL description="Veeqo-EasyPost Integration Platform"
LABEL version="1.0.0"