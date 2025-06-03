# Tierlist Builder

A modern, interactive tier list maker built with React, TypeScript, and Clean Architecture principles. Create and customize tier lists with drag-and-drop functionality, image uploads, and real-time editing.

## ✨ Features

- **🎯 Drag & Drop Interface** - Intuitive tier list creation with smooth interactions
- **📸 Image Upload** - Support for JPEG, PNG, GIF, and WebP formats
- **🎨 Customizable Tiers** - Color-coded tiers with editable labels
- **💾 Auto-save** - Real-time persistence with external database
- **📱 Responsive Design** - Works seamlessly on desktop and mobile
- **🔧 Clean Architecture** - Maintainable codebase with separation of concerns
- **🚀 Modern Stack** - Built with React 19, TypeScript, Bun, and TailwindCSS

## 🏗️ Architecture

This project follows Clean Architecture principles with clear separation between:

- **Core Layer** - Business entities and use cases
- **Infrastructure Layer** - Database and storage implementations  
- **Presentation Layer** - React components and UI
- **Features Layer** - Domain-specific functionality
- **Shared Layer** - Reusable utilities and components

## 🚀 Quick Start

### Prerequisites

- [Bun](https://bun.sh/) (latest version)
- [Docker](https://www.docker.com/) & Docker Compose (for containerized setup)
- Database provider (PostgreSQL-compatible)
- S3-compatible storage provider (Vultr, AWS S3, etc.) or local MinIO

### Local Development

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd tierlist-builder
   ```

2. **Install dependencies**
   ```bash
   bun install
   ```

3. **Configure environment**
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

4. **Start development server**
   ```bash
   bun run dev
   ```

5. **Open your browser**
   ```
   http://localhost:3000
   ```

### Docker Development Setup

For a complete development environment with local services:

```bash
# Start app with local S3-compatible storage
docker-compose --profile local-storage up

# Start app with caching
docker-compose --profile local-storage --profile cache up

# Access MinIO Console at http://localhost:9001
# Access app at http://localhost:3000
```

## 🔧 Configuration

### Environment Variables

Copy `.env.example` to `.env` and configure the following:

#### Required Configuration

```env
# Database (PostgreSQL-compatible)
DATABASE_URL=https://your-project-id.example.co
DATABASE_ANON_KEY=your-database-anon-key

# Object Storage (Vultr, AWS S3, DigitalOcean Spaces, etc.)
S3_ENDPOINT=https://ewr1.vultrobjects.com
S3_ACCESS_KEY=your-access-key
S3_SECRET_KEY=your-secret-key
S3_BUCKET_NAME=tierlist-images
S3_REGION=us-east-1
```

#### Optional Configuration

```env
# Application settings
APP_NAME="Your Tierlist App"
MAX_IMAGE_SIZE=5242880  # 5MB
MAX_TIER_ITEMS=50
MAX_TIERS=10

# Performance
AUTO_SAVE_INTERVAL=30000  # 30 seconds
```

### External Services Setup

#### Database Setup

1. Create a PostgreSQL-compatible database (Supabase, Neon, Railway, local, etc.)
2. Get your project URL and anon key from your provider's dashboard (if required)

#### Object Storage

**Production (Object Storage):**
1. Create an account on a provider proposing a S3 compatible Object Storage service
2. Create an Object Storage subscription
3. Create a bucket for your images
4. Get your access keys from the dashboard

**Development (Local MinIO):**
See [docs/MINIO_SETUP.md](./docs/MINIO_SETUP.md) for detailed MinIO configuration.

## 🏭 Production Deployment

### Docker Production Setup

1. **Prepare environment**
   ```bash
   cp .env.example .env.production
   # Configure production variables
   ```

2. **Build and deploy**
   ```bash
   DOCKER_TARGET=production docker-compose --profile production up --build -d
   ```

3. **Access your app**
   - HTTP: `http://your-domain`
   - HTTPS: `https://your-domain` (automatic with Caddy)
   - Admin: `http://your-domain:2019` (Caddy admin)

### Production Environment Variables

```env
NODE_ENV=production
DOMAIN=your-domain.com
HTTP_PORT=80
HTTPS_PORT=443

# Use production database and storage
DATABASE_URL=https://your-production-db.example.co
S3_ENDPOINT=https://your-production-storage.com
```

## 📝 Available Scripts

```bash
# Development
bun run dev          # Start development server
bun run build        # Build for production
bun run start        # Start production server

# Code Quality
bun run lint         # Run ESLint
bun run lint:fix     # Fix ESLint issues
bun run format       # Format with Prettier
bun run format:check # Check formatting
bun run type-check   # Run TypeScript checks
bun run quality      # Run all quality checks

# Testing
bun run test         # Run tests
bun run test:watch   # Run tests in watch mode
bun run test:coverage # Run tests with coverage
```

## 🛠️ Development

### Project Structure

```
src/
├── core/           # Business logic and entities
├── infrastructure/ # External services (database, storage)
├── presentation/   # Pages and layouts
├── features/       # Feature-specific components
├── shared/         # Shared utilities and UI components
└── app/           # Application providers and configuration
```

### Adding New Features

1. Define entities in `src/core/entities/`
2. Create use cases in `src/core/use-cases/`
3. Implement infrastructure in `src/infrastructure/`
4. Build UI components in `src/features/`
5. Write tests for all layers

## 🧪 Testing

Run the test suite:

```bash
# Unit tests
bun run test

# Watch mode
bun run test:watch

# Coverage report
bun run test:coverage
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Commit your changes: `git commit -m 'Add amazing feature'`
4. Push to the branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

## 📚 Documentation

- [MinIO Setup](./docs/MINIO_SETUP.md) - Local storage configuration

## 🐛 Troubleshooting

### Common Issues

**Build fails with TypeScript errors:**
```bash
bun run type-check
```

**Images not uploading:**
- Check S3 credentials and bucket permissions
- Verify file size limits (default 5MB)
- Ensure bucket CORS is configured

**Database connection issues:**
- Verify database URL and anon key
- Check database permissions
- Ensure tables exist

### Docker Issues

**Container won't start:**
```bash
# Check logs
docker-compose logs app

# Rebuild containers
docker-compose build --no-cache
```

**MinIO access issues:**
```bash
# Check MinIO logs
docker-compose logs minio

# Reset MinIO data
docker-compose down -v
docker-compose --profile local-storage up
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [React](https://reactjs.org/) - UI library
- [TypeScript](https://www.typescriptlang.org/) - Type safety
- [Bun](https://bun.sh/) - Fast runtime and package manager
- [TailwindCSS](https://tailwindcss.com/) - Utility-first CSS
- [PostgreSQL](https://www.postgresql.org/) - Database system
- [MinIO](https://min.io/) - S3-compatible object storage
- [Caddy](https://caddyserver.com/) - Modern web server