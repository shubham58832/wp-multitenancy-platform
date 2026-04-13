#!/bin/bash

# Default IP fallback
SERVER_IP="127.0.0.1"

# Load environment variables if .env exists
if [ -f .env ]; then
  # Extract SERVER_IP specifically
  SERVER_IP=$(grep -E "^SERVER_IP=" .env | cut -d '=' -f2)
else
  echo -e "\e[33m Warning: .env file not found. Using default IP.\e[0m"
fi

echo ""
echo -e "\e[32m Public Tenants:\e[0m"
echo -e "   Tenant 1: http://${SERVER_IP}/tenant1/"
echo -e "   Tenant 2: http://${SERVER_IP}/tenant2/"
echo ""
echo -e "\e[33m Admin Dashboards:\e[0m"
echo -e "   Tenant 1 Admin: http://${SERVER_IP}/tenant1/wp-admin/"
echo -e "   Tenant 2 Admin: http://${SERVER_IP}/tenant2/wp-admin/"
echo ""
echo -e "\e[35m Observability & Metrics:\e[0m"
echo -e "   Grafana Dashboard:   http://${SERVER_IP}:3001  (Login: admin/admin)"
echo -e "   Prometheus:          http://${SERVER_IP}:9090"
echo -e "   NGINX Exporter:      http://${SERVER_IP}:8088/stub_status"
echo ""
