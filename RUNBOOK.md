# Platform RUNBOOK

## Observability Stack

The platform includes a bundled cloud-native observability stack.

### 1. Centralized Logs (Loki + Promtail + Grafana)
* **Access**: http://localhost:3000 (Grafana)
* **Explore Logs**: Go to `Explore` -> Select `Loki` as datasource.
* **Example Query**: `{container="wp-multitenant-tenant1-1"}` to view logs specifically for Tenant 1.
* *How it works*: Promtail mounts the docker socket, automatically discovers all containers, and streams their stdout/stderr directly into Loki for centralized querying.

### 2. Metrics (Prometheus + cAdvisor)
* **Access**: http://localhost:9090 (Prometheus)
* **What is scraped**: NGINX Exporter (request rates, connections), cAdvisor (CPU, Memory per container).

### 3. Dashboards
* **Access**: http://localhost:3000/dashboards
* **Platform Health Dashboard**: Displays the `up` state of critical containers.

## Alerts

*(In a full production scenario, these are evaluated by Prometheus and sent to Alertmanager. Locally, you can view the queries in Prometheus / Grafana Alerting tab).*

1. **Availability Alert**:
   * *Threshold*: `up == 0` for 1m
   * *Action*: Check if a container crashed using `docker ps`. Restart via `docker-compose restart <service>`.
2. **High Connection Rate Alert (NGINX)**:
   * *Threshold*: `rate(nginx_http_requests_total[5m]) > 100` (example value)
   * *Action*: Indicates high traffic or potential DoS. Check the WordPress error logs in Loki or scale up. Check CPU utilization via cAdvisor.
3. **Database Health Alert**:
   * *Threshold*: Prometheus cannot scrape MySQL exporter (if added), or `mysql` container is down.
   * *Action*: Check Docker logs `docker logs wp-multitenant-mysql-1`. If Out-Of-Memory (OOM), increase Docker memory limits.

## Operational Tasks

**Restarting a Tenant**:
```bash
docker-compose restart tenant1
```

**Executing WP-CLI commands**:
```bash
docker-compose exec tenant1 wp --allow-root cache flush
```

**Taking a manual database dump for a tenant**:
```bash
docker-compose exec mysql mysqldump -u tenant1_user -ptenant1_password tenant1_db > tenant1_backup.sql
```
