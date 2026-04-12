# WordPress Multitenancy Platform

A local, Docker Compose based platform that hosts multiple isolated WordPress tenants, complete with observability (Prometheus, Grafana, Loki) and a centralized reverse-proxy.

## Architecture

* **NGINX**: Central reverse proxy routing requests via Host headers (e.g. `tenant1.localhost`).
* **MySQL**: One shared database instance hosting multiple isolated logical databases (`tenant1_db`, `tenant2_db`).
* **WordPress**: One container per tenant. This provides strict filesystem isolation.
* **Observability**: Prometheus (metrics), Loki (logs), Promtail (log scraping), cAdvisor (container metrics), and Grafana (dashboards).

## Setup Instructions

**Prerequisites:**
* Docker and Docker Compose installed.

**One-Command Startup:**
```bash
docker-compose up -d
```
*Wait ~30 seconds for the database to initialize and WordPress to extract its files.*

**Access Points:**
* NGINX Prometheus Exporter: http://localhost:8080/stub_status
* Tenant 1: http://tenant1.localhost
* Tenant 2: http://tenant2.localhost
* Grafana: http://localhost:3000 (admin / admin)
* Prometheus: http://localhost:9090

## Onboarding a New Tenant (e.g., Tenant 3)

1. **Update `init-scripts/init-db.sql`**:
   Add the following lines:
   ```sql
   CREATE DATABASE IF NOT EXISTS tenant3_db;
   CREATE USER IF NOT EXISTS 'tenant3_user'@'%' IDENTIFIED BY 'tenant3_password';
   GRANT ALL PRIVILEGES ON tenant3_db.* TO 'tenant3_user'@'%';
   FLUSH PRIVILEGES;
   ```
   *(Note: If the DB is already running, apply this manually inside the MySQL container).*

2. **Update `docker-compose.yml`**:
   Copy the `tenant2` block, rename everything to `tenant3`.
   ```yaml
   tenant3:
     image: wordpress:latest
     environment:
       WORDPRESS_DB_HOST: mysql
       WORDPRESS_DB_USER: tenant3_user
       WORDPRESS_DB_PASSWORD: tenant3_password
       WORDPRESS_DB_NAME: tenant3_db
       WORDPRESS_CONFIG_EXTRA: |
         define('WP_HOME', 'http://tenant3.localhost');
         define('WP_SITEURL', 'http://tenant3.localhost');
     volumes:
       - tenant3_data:/var/www/html
     networks:
       - wp_net
     depends_on:
       - mysql
     logging:
       driver: "json-file"
   ```
   Don't forget to add `tenant3_data:` under the `volumes:` section at the bottom!

3. **Update `config/nginx/nginx.conf`**:
   Add a new server block for `tenant3`:
   ```nginx
   server {
       listen 80;
       server_name tenant3.localhost;

       location / {
           proxy_pass http://tenant3:80;
           proxy_set_header Host $host;
           proxy_set_header X-Real-IP $remote_addr;
           proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
           proxy_set_header X-Forwarded-Proto $scheme;
       }
   }
   ```

4. **Apply the Changes**:
   ```bash
   docker-compose up -d
   docker-compose restart nginx
   ```
   NGINX requires a restart or reload to pick up the new configuration, and will then route `tenant3.localhost` to the new container!

## Versioning and Rollbacks

**Versioning Strategy**:
We use semantic versioning strictly tied to Git Tags (e.g., `v1.2.0`) in the CD pipeline. Merges to `main` without tags fall back to short commit SHAs (e.g., `abc1234`).
The CI/CD pipeline builds `theme-v1.2.0.zip` and uploads it.

**Rollback Strategy**:
Since artifacts are immutable and named by version, a rollback consists of downloading the previous stable version artifact (e.g., `theme-v1.1.0.zip`) from GitHub Actions, extracting it into the tenant's volume, and activating it using `wp-cli`:
```bash
docker-compose exec tenant1 wp theme activate my-theme-1.1.0
```
There is no "revert commit and push" needed for emergency rollbacks; you deploy the previous verified artifact.
