# Runbook

Quick commands and notes for operating the platform.

## Commands

Restart a site:
```bash
docker-compose restart tenant1
```

Flush cache (WP-CLI):
```bash
docker-compose exec tenant1 wp --allow-root cache flush
```

Database dump:
```bash
docker-compose exec mysql mysqldump -u root -p tenant1_db > backup.sql
```

## Logs and Metrics

* Grafana runs on port 3000/3001.
* Prometheus runs on port 9090.
* Logs are pushed via Promtail to Loki. You can query them in the Grafana Explore tab using `{container="wp-multitenant-tenant1-1"}`.

If Nginx rate alerts fire, check the logs for DoS attempts or scale the containers. If MySQL dies, check OOM errors (`docker logs wp-multitenant-mysql-1`).

