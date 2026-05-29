# Production-ready Dockerfile for Hospital Management System
# Multi-stage build for optimized image size and security

# Stage 1: Dependencies
FROM node:20-alpine AS dependencies

LABEL stage=dependencies

WORKDIR /app/backend

# Copy package files
COPY backend/package*.json ./

# Install dependencies - production only, no dev dependencies
RUN npm ci --omit=dev && npm cache clean --force

# Stage 2: Runtime
FROM node:20-alpine AS runtime

LABEL maintainer="DevOps Team" \
      version="1.0.0" \
      description="Hospital Management System - Node.js Express Application"

# Production environment variables
ENV NODE_ENV=production \
    PORT=5000 \
    NPM_CONFIG_LOGLEVEL=error

WORKDIR /app

# Install dumb-init to handle signals properly
RUN apk add --no-cache dumb-init

# Copy dependencies from build stage with proper ownership
COPY --from=dependencies --chown=node:node /app/backend/node_modules ./backend/node_modules

# Copy application and public files
COPY --chown=node:node backend ./backend
COPY --chown=node:node public ./public

# Switch to non-root user for security
USER node

# Set working directory for application
WORKDIR /app/backend

# Health check endpoints
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
  CMD node -e "require('http').get('http://localhost:5000/healthz', (r) => {if(r.statusCode !== 200) throw new Error(r.statusCode);})"

# Expose application port
EXPOSE 5000

# Use dumb-init to handle signals (graceful shutdown)
ENTRYPOINT ["dumb-init", "--"]

# Start application
CMD ["node", "app.js"]
