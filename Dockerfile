# Tierlist Builder - Multi-stage Dockerfile
# Supports both development and production builds with Bun

# ========================
# Base Stage - Common dependencies
# ========================
FROM oven/bun:1-alpine AS base

WORKDIR /app

# Install system dependencies for better compatibility
RUN apk add --no-cache \
    curl \
    && rm -rf /var/cache/apk/*

COPY package.json bun.lock* ./

RUN bun install --frozen-lockfile

# ========================
# Development Stage
# ========================
FROM base AS development

ENV NODE_ENV=development

COPY . .

EXPOSE 3000

# Health check for development
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:3000 || exit 1

# Start development server with hot reload
CMD ["bun", "run", "dev"]

# ========================
# Build Stage - Create production build
# ========================
FROM base AS builder

ENV NODE_ENV=production

COPY . .

RUN bun run build

# ========================
# Production Stage - Optimized runtime
# ========================
FROM oven/bun:1-alpine AS production

ENV NODE_ENV=production

# Create non-root user for security
RUN addgroup -g 1001 -S nodejs \
    && adduser -S bunuser -u 1001 -G nodejs

WORKDIR /app

# Install only production system dependencies
RUN apk add --no-cache \
    curl \
    tini \
    && rm -rf /var/cache/apk/*

# Copy built application from builder stage
COPY --from=builder --chown=bunuser:nodejs /app/dist ./dist
COPY --from=builder --chown=bunuser:nodejs /app/package.json ./
COPY --from=builder --chown=bunuser:nodejs /app/bun.lock* ./

# Copy production dependencies
COPY --from=builder --chown=bunuser:nodejs /app/node_modules ./node_modules

# Copy static files
COPY --from=builder --chown=bunuser:nodejs /app/index.html ./
COPY --from=builder --chown=bunuser:nodejs /app/public ./public

USER bunuser

EXPOSE 3000

# Health check for production
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:3000 || exit 1

# Use tini as entrypoint for proper signal handling
ENTRYPOINT ["/sbin/tini", "--"]

# Start production server
CMD ["bun", "run", "start"]

# ========================
# Testing Stage - For CI/CD
# ========================
FROM base AS testing

ENV NODE_ENV=test

COPY . .

# Run tests, linting, and type checking
RUN bun run quality && \
    bun run test --coverage --watchAll=false

# Default command for testing
CMD ["bun", "run", "test"]

# ========================
# Build metadata
# ========================
LABEL maintainer="Tierlist Builder Team"
LABEL description="Modern tierlist maker with React, TypeScript, and Bun"
LABEL version="1.0.0"
LABEL org.opencontainers.image.source="https://github.com/your-username/tierlist-builder"
LABEL org.opencontainers.image.description="Interactive tier list builder with drag-and-drop functionality"
LABEL org.opencontainers.image.licenses="MIT"