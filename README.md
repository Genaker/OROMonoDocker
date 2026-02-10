# OROMonoDocker

[![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=flat&logo=docker&logoColor=white)](https://www.docker.com/)
[![PHP](https://img.shields.io/badge/php-8.3-%23777BB4.svg?style=flat&logo=php&logoColor=white)](https://www.php.net/)
[![PostgreSQL](https://img.shields.io/badge/postgresql-13-%23316192.svg?style=flat&logo=postgresql&logoColor=white)](https://www.postgresql.org/)

A comprehensive, all-in-one Docker container for [ORO Commerce CRM](https://oroinc.com/orocommerce/) with all required services pre-configured and ready to use. This mono-container approach simplifies deployment and development by packaging Nginx, PHP 8.3, PostgreSQL, Redis, and the ORO Commerce application in a single container.

> **⚠️ IMPORTANT**: This is a **development/demo container** with all services in a single container. **DO NOT use in production** without proper security hardening. For production deployments, use a multi-container architecture with separate containers for each service, proper secret management, and orchestration (Kubernetes, Docker Swarm, etc.).

## 📋 Table of Contents

- [Features](#-features)
- [What's Included](#-whats-included)
- [Prerequisites](#-prerequisites)
- [Quick Start](#-quick-start)
- [Building the Image](#-building-the-image)
- [Running the Container](#-running-the-container)
- [Configuration](#-configuration)
- [Architecture](#-architecture)
- [Accessing ORO Commerce](#-accessing-oro-commerce)
- [Services Management](#-services-management)
- [Troubleshooting](#-troubleshooting)
- [Performance Tuning](#-performance-tuning)
- [Contributing](#-contributing)
- [License](#-license)

## 🚀 Features

- **All-in-One Container**: Single Docker container with all ORO Commerce dependencies
- **Development-Optimized**: Pre-configured with optimized PHP and Nginx settings for development
- **Latest Stack**: PHP 8.3, PostgreSQL 13, Node.js 20, Redis
- **Demo Data**: Includes demo fixtures for quick testing and evaluation
- **Easy Setup**: Minimal configuration required to get started
- **Mono-Container Design**: Simplified deployment and management for development/testing

## 📦 What's Included

This Docker image includes the following components:

| Component | Version | Description |
|-----------|---------|-------------|
| **Base OS** | Ubuntu 24.04 LTS | Stable and secure Linux foundation |
| **PHP** | 8.3 | With FPM and all required ORO extensions |
| **Nginx** | Latest | Web server with optimized ORO configuration |
| **PostgreSQL** | 13+ | Database server with uuid-ossp extension |
| **Redis** | Latest | Cache and session storage |
| **Node.js** | 20.x | JavaScript runtime for asset compilation |
| **Composer** | Latest | PHP dependency manager |
| **ORO Commerce CRM** | 6.0.3 | Complete B2B eCommerce platform |

### PHP Extensions

- `pdo`, `mysqlnd`, `pgsql` - Database connectivity
- `xml`, `soap` - Web services
- `gd`, `intl` - Internationalization and graphics
- `zip`, `mbstring` - File handling and string operations
- `opcache`, `bcmath` - Performance and calculations
- `curl`, `ldap` - Network and authentication
- `mongodb` - NoSQL database support

## 📋 Prerequisites

- Docker installed on your system ([Install Docker](https://docs.docker.com/get-docker/))
- At least 4GB of available RAM
- 10GB of free disk space
- Basic knowledge of Docker commands

## ⚡ Quick Start

### Pull and Run (Pre-built Image)

If a pre-built image is available on Docker Hub:

```bash
# Pull the image (when available)
docker pull genaker/oro-mono-docker:latest

# Run the container
docker run -d -p 80:80 --name oro-commerce genaker/oro-mono-docker:latest
```

### Build and Run

```bash
# Clone the repository
git clone https://github.com/Genaker/OROMonoDocker.git
cd OROMonoDocker

# Build the image (this will take 15-30 minutes)
docker build -t oro-mono-docker .

# Run the container
docker run -d -p 80:80 --name oro-commerce oro-mono-docker

# Start the services inside the container
docker exec -it oro-commerce bash -c "service php8.3-fpm start && service nginx start && service postgresql start && service redis-server start"
```

Access ORO Commerce at `http://localhost`

## 🔨 Building the Image

Building the image will take approximately 15-30 minutes depending on your internet connection and system resources:

```bash
docker build -t oro-mono-docker .
```

The build process:
1. Installs Ubuntu 24.04 base system
2. Configures PHP 8.3 with all extensions
3. Installs and configures Nginx
4. Sets up PostgreSQL database
5. Installs Redis server
6. Downloads and installs ORO Commerce 6.0.3
7. Runs ORO installation and loads demo data
8. Compiles and installs assets

## 🏃 Running the Container

### Basic Run

```bash
docker run -d -p 80:80 --name oro-commerce oro-mono-docker
```

### Run with Custom Port

```bash
docker run -d -p 8080:80 --name oro-commerce oro-mono-docker
```

### Run with Volume Mounting

To persist data and enable easier debugging:

```bash
docker run -d -p 80:80 \
  -v $(pwd)/oro-data:/var/www/html/oro \
  -v $(pwd)/pg-data:/var/lib/postgresql/13/main \
  --name oro-commerce oro-mono-docker
```

### Start All Services

After running the container, start all services:

```bash
docker exec -it oro-commerce bash -c "service php8.3-fpm start && service nginx start && service postgresql start && service redis-server start"
```

Or create a startup script inside the container:

```bash
docker exec -it oro-commerce bash -c 'cat << "EOF" > /usr/local/bin/start-services.sh
#!/bin/bash
service php8.3-fpm start
service nginx start
service postgresql start
service redis-server start
EOF
chmod +x /usr/local/bin/start-services.sh'

# Run the startup script
docker exec -it oro-commerce /usr/local/bin/start-services.sh
```

## ⚙️ Configuration

### Environment Variables

The container uses the following default database configuration:

```bash
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_DB=oro
ORO_DB_DRIVER=pdo_pgsql
ORO_DB_HOST=localhost
ORO_DB_PORT=5432
ORO_DB_USER=postgres
ORO_DB_PASSWORD=postgres
ORO_DB_NAME=oro
```

### PHP Configuration

PHP is configured with the following optimizations (located in `/etc/php/8.3/fpm/php.ini`):

```ini
memory_limit = 2048M
max_input_time = 600
max_execution_time = 600
realpath_cache_size = 4096K
realpath_cache_ttl = 600
opcache.enable = 1
opcache.enable_cli = 0
opcache.memory_consumption = 512
opcache.interned_strings_buffer = 32
opcache.max_accelerated_files = 32531
opcache.save_comments = 1
```

### Nginx Configuration

The Nginx configuration is located at `/etc/nginx/conf.d/default.conf` and is pre-configured for ORO Commerce with:
- Document root: `/var/www/html/oro/public`
- PHP-FPM socket: `/run/php/php8.3-fpm.sock`
- Static file caching (1 hour)
- Proper routing for ORO index files

## 🏗️ Architecture

```
┌─────────────────────────────────────────┐
│         OROMonoDocker Container         │
│                                         │
│  ┌─────────┐  ┌──────────────────────┐ │
│  │  Nginx  │→→│    PHP 8.3-FPM       │ │
│  │  :80    │  │ (ORO Commerce App)   │ │
│  └─────────┘  └──────────────────────┘ │
│                          ↓              │
│                    ┌──────────┐         │
│                    │PostgreSQL│         │
│                    │  :5432   │         │
│                    └──────────┘         │
│                          ↓              │
│                    ┌──────────┐         │
│                    │  Redis   │         │
│                    │  :6379   │         │
│                    └──────────┘         │
└─────────────────────────────────────────┘
```

### Component Responsibilities

- **Nginx**: Web server handling HTTP requests and serving static assets
- **PHP-FPM**: Application server running ORO Commerce
- **PostgreSQL**: Primary database for ORO data
- **Redis**: Cache and session storage for improved performance
- **Node.js**: Used during build for asset compilation

## 🌐 Accessing ORO Commerce

### Default Access

Once all services are running, access the application:

- **Frontend**: http://localhost
- **Backend**: http://localhost/admin

### Default Credentials

The default admin credentials (after demo data installation):

- **Username**: `admin`
- **Password**: `admin`

**🔒 SECURITY WARNING**: These are **demo credentials only**! 
- Change these credentials **immediately** on first login
- Never use these default credentials in any environment accessible from the internet
- This applies to development, staging, and production environments
- Consider implementing strong password policies and multi-factor authentication

## 🔧 Services Management

### Check Service Status

```bash
docker exec -it oro-commerce bash -c "service --status-all"
```

### Start Individual Services

```bash
# Start PHP-FPM
docker exec -it oro-commerce service php8.3-fpm start

# Start Nginx
docker exec -it oro-commerce service nginx start

# Start PostgreSQL
docker exec -it oro-commerce service postgresql start

# Start Redis
docker exec -it oro-commerce service redis-server start
```

### Restart Services

```bash
docker exec -it oro-commerce service php8.3-fpm restart
docker exec -it oro-commerce service nginx restart
```

### View Service Logs

```bash
# Nginx logs
docker exec -it oro-commerce tail -f /var/log/nginx/localhost_error.log
docker exec -it oro-commerce tail -f /var/log/nginx/localhost_access.log

# PHP-FPM logs
docker exec -it oro-commerce tail -f /var/log/php8.3-fpm.log
```

## 🔍 Troubleshooting

### Container Won't Start

```bash
# Check container logs
docker logs oro-commerce

# Check if port 80 is already in use
netstat -tulpn | grep :80

# Try running on a different port
docker run -d -p 8080:80 --name oro-commerce oro-mono-docker
```

### Services Not Running

```bash
# Enter the container
docker exec -it oro-commerce bash

# Start all services manually
service php8.3-fpm start
service nginx start
service postgresql start
service redis-server start

# Check service status
service --status-all
```

### Database Connection Issues

```bash
# Check PostgreSQL is running
docker exec -it oro-commerce service postgresql status

# Test database connection
docker exec -it oro-commerce psql -h localhost -U postgres -d oro -c '\l'

# Restart PostgreSQL
docker exec -it oro-commerce service postgresql restart
```

### Permission Issues

```bash
# Fix permissions on ORO directory (development only)
# Using 775 for directories allows read/write/execute for owner and group
docker exec -it oro-commerce chmod -R 775 /var/www/html/oro/var/cache
docker exec -it oro-commerce chmod -R 775 /var/www/html/oro/var/logs
docker exec -it oro-commerce chmod -R 775 /var/www/html/oro/public/media

# Better approach: set proper ownership to the web server user
docker exec -it oro-commerce chown -R www-data:www-data /var/www/html/oro/var
docker exec -it oro-commerce chown -R www-data:www-data /var/www/html/oro/public/media

# For more restrictive file permissions (files: 664, directories: 775)
docker exec -it oro-commerce bash -c "find /var/www/html/oro/var -type d -exec chmod 775 {} \;"
docker exec -it oro-commerce bash -c "find /var/www/html/oro/var -type f -exec chmod 664 {} \;"
```

### Clear ORO Cache

```bash
docker exec -it oro-commerce bash -c "cd /var/www/html/oro && php bin/console cache:clear --env=prod"
```

### Message Queue Consumer

To process background jobs:

```bash
# Memory limit options (bytes):
# - 500 MiB = 500 × 1024 × 1024 = 524,288,000 bytes (binary units)
# - 500 MB  = 500 × 1000 × 1000 = 500,000,000 bytes (decimal units)
docker exec -it oro-commerce bash -c "cd /var/www/html/oro && php bin/console oro:message-queue:consume --memory-limit=524288000"
```

## ⚡ Performance Tuning

### Increase Container Resources

```bash
# Run with more memory and CPU
docker run -d -p 80:80 \
  --memory="4g" \
  --cpus="2" \
  --name oro-commerce oro-mono-docker
```

### Optimize PHP-FPM

Edit `/etc/php/8.3/fpm/pool.d/www.conf` inside the container:

```ini
pm = dynamic
pm.max_children = 50
pm.start_servers = 10
pm.min_spare_servers = 5
pm.max_spare_servers = 20
```

### Enable Production Mode

```bash
docker exec -it oro-commerce bash -c "cd /var/www/html/oro && php bin/console cache:clear --env=prod"
```

## 🛠️ Development Usage

### Interactive Shell

```bash
docker exec -it oro-commerce bash
```

### Run ORO Commands

```bash
# Using the symfony alias
docker exec -it oro-commerce symfony oro:user:list

# Or directly
docker exec -it oro-commerce bash -c "cd /var/www/html/oro && php bin/console oro:user:list"
```

### Update Dependencies

```bash
docker exec -it oro-commerce bash -c "cd /var/www/html/oro && composer update"
```

### Run Asset Build

```bash
docker exec -it oro-commerce bash -c "cd /var/www/html/oro && php bin/console oro:assets:install"
```

## 📝 Useful Commands

### Backup Database

```bash
docker exec -it oro-commerce pg_dump -U postgres oro > oro_backup_$(date +%Y%m%d).sql
```

### Restore Database

```bash
cat oro_backup.sql | docker exec -i oro-commerce psql -U postgres oro
```

### Monitor Resource Usage

```bash
docker stats oro-commerce
```

## 🤝 Contributing

Contributions are welcome! Here's how you can help:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Contribution Ideas

- Add support for different ORO Commerce versions
- Improve build time optimization
- Add health check endpoints
- Create docker-compose variant
- Add CI/CD pipeline examples
- Improve documentation

## 📄 License

This project is provided as-is for educational and development purposes. Please refer to [ORO Commerce licensing](https://oroinc.com/orocommerce/licensing) for the application itself.

## 🔗 Useful Links

- [ORO Commerce Official Site](https://oroinc.com/orocommerce/)
- [ORO Commerce Documentation](https://doc.oroinc.com/)
- [ORO Commerce GitHub](https://github.com/oroinc/orocommerce)
- [Docker Documentation](https://docs.docker.com/)
- [ORO Commerce System Requirements](https://doc.oroinc.com/backend/setup/system-requirements/)

## 📧 Support

For issues specific to this Docker container, please open an issue in this repository.

For ORO Commerce application issues, please refer to the [official ORO support channels](https://oroinc.com/contact-us/).

---

**Note**: This is a development/demo container with all services in a single container. For production deployments, consider using a multi-container architecture with separate containers for each service and proper orchestration (Kubernetes, Docker Swarm, etc.).
