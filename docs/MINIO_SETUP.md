# MinIO Setup Guide

This guide covers setting up MinIO for local development and production deployment as an S3-compatible object storage solution for the Tierlist Builder project.

## 📋 Overview

MinIO is a high-performance, S3-compatible object storage solution that's perfect for development and production environments. It provides the same API as Amazon S3, making it easy to develop locally and migrate to production.

### Why MinIO?

- **S3 Compatible** - Works with existing S3 SDKs and tools
- **High Performance** - Production throughput in excess of 2.2 TiB/s
- **Cost Effective** - Save 70-80% compared to cloud storage for large datasets
- **Easy Setup** - Single binary deployment with Docker support
- **Developer Friendly** - Perfect for local development and testing

## 🚀 Local Development Setup

### Using Docker Compose (Recommended)

The project includes MinIO in the docker-compose.yml file. To start it:

```bash
# Start the app with MinIO storage
docker-compose --profile local-storage up

# Start with both storage and cache
docker-compose --profile local-storage --profile cache up
```

### Access MinIO Services

- **MinIO API**: http://localhost:9000
- **MinIO Console**: http://localhost:9001
- **Default Credentials**: 
  - Username: `minioadmin` (or your `S3_ACCESS_KEY`)
  - Password: `minioadmin123` (or your `S3_SECRET_KEY`)

### Manual Docker Setup

If you prefer to run MinIO separately:

```bash
# Create data directory
mkdir -p ~/minio/data

# Run MinIO container
docker run \
  -p 9000:9000 \
  -p 9001:9001 \
  -v ~/minio/data:/data \
  -e "MINIO_ROOT_USER=minioadmin" \
  -e "MINIO_ROOT_PASSWORD=minioadmin123" \
  quay.io/minio/minio server /data --console-address ":9001"
```

### Standalone Installation

For development without Docker:

```bash
# Download MinIO (Linux/macOS)
curl https://dl.min.io/server/minio/release/linux-amd64/minio \
  -o minio
chmod +x minio

# Windows (PowerShell)
Invoke-WebRequest -Uri "https://dl.min.io/server/minio/release/windows-amd64/minio.exe" -OutFile "C:\minio.exe"

# Start MinIO
export MINIO_ROOT_USER=minioadmin
export MINIO_ROOT_PASSWORD=minioadmin123
./minio server /data --console-address ":9001"
```

## 🏗️ Initial Configuration

### 1. Create Bucket

After starting MinIO, create a bucket for your tierlist images:

**Via MinIO Console:**
1. Open http://localhost:9001
2. Login with your credentials
3. Click "Create Bucket"
4. Name it `tierlist-images` (or match your `S3_BUCKET_NAME`)
5. Click "Create Bucket"

**Via CLI:**
```bash
# Install MinIO Client
curl https://dl.min.io/client/mc/release/linux-amd64/mc \
  -o mc
chmod +x mc

# Configure alias
./mc alias set local http://localhost:9000 minioadmin minioadmin123

# Create bucket
./mc mb local/tierlist-images

# Set public read policy (for image serving)
./mc anonymous set public local/tierlist-images
```

### 2. Configure CORS (Important!)

For web applications to upload directly to MinIO, configure CORS:

**Via MinIO Console:**
1. Go to Buckets → tierlist-images → Summary
2. Click "Edit" in Access Policy section
3. Add CORS rules:

```json
{
  "CORSRules": [
    {
      "AllowedOrigins": ["http://localhost:3000", "https://your-domain.com"],
      "AllowedMethods": ["GET", "PUT", "POST", "DELETE"],
      "AllowedHeaders": ["*"],
      "ExposeHeaders": ["ETag"]
    }
  ]
}
```

**Via CLI:**
```bash
# Create cors.json file
cat > cors.json << EOF
{
  "CORSRules": [
    {
      "AllowedOrigins": ["*"],
      "AllowedMethods": ["GET", "PUT", "POST", "DELETE"],
      "AllowedHeaders": ["*"],
      "ExposeHeaders": ["ETag"]
    }
  ]
}
EOF

# Apply CORS configuration
./mc admin config set local api cors_enabled=on
./mc admin service restart local
```

### 3. Environment Configuration

Update your `.env` file for local MinIO:

```env
# Local MinIO Configuration
S3_ENDPOINT=http://localhost:9000
S3_ACCESS_KEY=minioadmin
S3_SECRET_KEY=minioadmin123
S3_BUCKET_NAME=tierlist-images
S3_REGION=us-east-1
S3_PORT=9000
S3_CONSOLE_PORT=9001
```

## 🏭 Production Deployment

### Docker Compose Production

For production deployment with persistent storage:

```yaml
# docker-compose.prod.yml
version: '3.8'

services:
  minio:
    image: quay.io/minio/minio:latest
    container_name: minio-production
    ports:
      - "9000:9000"
      - "9001:9001"
    volumes:
      - minio-data:/data
      - ./config:/root/.minio
    environment:
      - MINIO_ROOT_USER=${S3_ACCESS_KEY}
      - MINIO_ROOT_PASSWORD=${S3_SECRET_KEY}
      - MINIO_BROWSER_REDIRECT_URL=https://your-domain.com:9001
      - MINIO_SERVER_URL=https://your-domain.com:9000
    command: server /data --console-address ":9001"
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:9000/minio/health/live"]
      interval: 30s
      timeout: 20s
      retries: 3
    networks:
      - production-network

  # Optional: Nginx proxy for MinIO
  minio-proxy:
    image: nginx:alpine
    ports:
      - "443:443"
    volumes:
      - ./nginx/minio.conf:/etc/nginx/nginx.conf:ro
      - ./ssl:/etc/ssl/certs:ro
    depends_on:
      - minio
    networks:
      - production-network

volumes:
  minio-data:
    driver: local

networks:
  production-network:
    driver: bridge
```

### Distributed MinIO (High Availability)

For production with high availability:

```bash
# 4-node distributed setup
docker run -d \
  --name minio1 \
  -p 9000:9000 \
  -p 9001:9001 \
  -v /data1:/data1 \
  -v /data2:/data2 \
  -e "MINIO_ROOT_USER=admin" \
  -e "MINIO_ROOT_PASSWORD=SecurePassword123!" \
  quay.io/minio/minio server \
    http://minio{1...4}/data{1...2} \
    --console-address ":9001"
```

### Security Best Practices

#### 1. Strong Credentials

```bash
# Generate secure credentials
export MINIO_ROOT_USER=$(openssl rand -hex 16)
export MINIO_ROOT_PASSWORD=$(openssl rand -hex 32)
```

#### 2. TLS/SSL Configuration

```bash
# Generate self-signed certificate for development
openssl req -new -newkey rsa:2048 -days 365 -nodes -x509 \
  -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost" \
  -keyout private.key -out public.crt

# Place certificates in MinIO certs directory
mkdir -p ~/.minio/certs
cp public.crt ~/.minio/certs/
cp private.key ~/.minio/certs/
```

#### 3. IAM Policies

Create limited access policies for applications:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject"
      ],
      "Resource": "arn:aws:s3:::tierlist-images/*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket"
      ],
      "Resource": "arn:aws:s3:::tierlist-images"
    }
  ]
}
```

## 🔧 Application Integration

### AWS SDK Configuration

Update your application to use MinIO:

```typescript
// src/infrastructure/storage/S3ImageUploadService.ts
import AWS from 'aws-sdk';

const s3 = new AWS.S3({
  endpoint: process.env.S3_ENDPOINT, // http://localhost:9000
  accessKeyId: process.env.S3_ACCESS_KEY,
  secretAccessKey: process.env.S3_SECRET_KEY,
  region: process.env.S3_REGION,
  s3ForcePathStyle: true, // Important for MinIO
  signatureVersion: 'v4'
});
```

### Upload Example

```typescript
async uploadImage(file: File): Promise<string> {
  const fileName = `tierlist-items/${Date.now()}-${file.name}`;
  
  const uploadParams = {
    Bucket: process.env.S3_BUCKET_NAME,
    Key: fileName,
    Body: file,
    ContentType: file.type,
    ACL: 'public-read'
  };

  try {
    const result = await this.s3.upload(uploadParams).promise();
    return result.Location;
  } catch (error) {
    throw new Error(`Failed to upload image: ${error.message}`);
  }
}
```

## 🔄 Migration to Production Storage

When moving from MinIO to cloud storage (Vultr, AWS S3, etc.):

### 1. Data Migration

```bash
# Using rclone for data migration
rclone copy minio:tierlist-images vultr:tierlist-images

# Or using AWS CLI
aws s3 sync s3://local-bucket s3://production-bucket \
  --endpoint-url http://localhost:9000
```

### 2. Configuration Update

Simply update your environment variables:

```env
# Change from MinIO
S3_ENDPOINT=http://localhost:9000

# To production (Vultr example)
S3_ENDPOINT=https://ewr1.vultrobjects.com
```

Your application code doesn't need changes due to S3 API compatibility!

## 📊 Monitoring & Maintenance

### Health Checks

```bash
# Check MinIO health
curl -f http://localhost:9000/minio/health/live

# Check storage usage
./mc admin info local

# Monitor performance
./mc admin trace local
```

### Backup Strategy

```bash
# Regular backup script
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
./mc mirror local/tierlist-images backup/tierlist-images-$DATE
```

### Log Management

```bash
# View MinIO logs
docker logs minio

# Enable audit logging
./mc admin config set local audit_webhook:webhook1 endpoint="http://your-log-server"
```

## 🐛 Troubleshooting

### Common Issues

**1. CORS Errors**
```bash
# Verify CORS configuration
./mc admin info local | grep cors

# Reset CORS
./mc admin config set local api cors_enabled=on
./mc admin service restart local
```

**2. Connection Refused**
```bash
# Check if MinIO is running
docker ps | grep minio

# Check port binding
netstat -tulpn | grep 9000
```

**3. Permission Denied**
```bash
# Check bucket policy
./mc stat local/tierlist-images

# Fix permissions
./mc policy set public local/tierlist-images
```

**4. Upload Failures**
```bash
# Check bucket exists
./mc ls local/

# Create if missing
./mc mb local/tierlist-images

# Verify credentials
./mc admin info local
```

### Performance Tuning

```bash
# Increase file descriptor limits
ulimit -n 65536

# Optimize for SSD storage
./mc admin config set local storage_class:standard ec=2
```

## 📚 Additional Resources

- [MinIO Documentation](https://min.io/docs/)
- [MinIO Docker Hub](https://hub.docker.com/r/minio/minio)
- [S3 API Compatibility](https://min.io/product/s3-compatibility)
- [MinIO Client (mc) Guide](https://min.io/docs/minio/linux/reference/minio-mc.html)
- [Production Deployment Guide](https://min.io/docs/minio/container/operations/install-deploy-manage.html)

---

This setup provides a robust, S3-compatible storage solution that seamlessly scales from local development to production deployment!