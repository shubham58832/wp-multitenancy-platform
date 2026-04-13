# WP Multitenant Setup

Local Docker Compose setup for hosting multiple WordPress sites behind a single NGINX proxy.
Includes logging and metrics (Prometheus, Grafana, Loki).
## Prerequisite
1. EC2 instance  min 2 cpu and min 4 Gb memory.
2. Docker and doker-compose install on that instance.

## Getting Started

1. Copy `.env.example` (if present) to `.env` or just use the defaults.
2. Run the environment:
```bash
docker-compose up -d
```
3. Wait a few seconds for MySQL to initialize.

## Access
- NGINX Proxy: :80
- Grafana: :3000 (admin/admin)
- Prometheus: :9090

Run `./show-urls.sh` to see the full list of endpoints.

## Adding a New Tenant
If you need to add another environment:
1. Add the db credentials to `init-scripts/init-db.sh`.
2. Add a new service block in `docker-compose.yml` (copy existing).
3. Update `config/nginx/nginx.conf` routing for the new path.
4. Restart docker containers.
