# Security Threat Model and Mitigations

This document outlines the security controls implemented in the WordPress Multitenancy Platform.

## 1. Tenant Isolation Risks
**Risk**: A vulnerable plugin allows an attacker to execute Remote Code Execution (RCE) on Tenant 1. If isolation is weak, the attacker could read credentials or modify files of Tenant 2.
**Mitigation**: 
* **Container Isolation**: Each tenant runs in a completely separate Docker container. They share the host kernel, but filesystem mounts (`var/www/html`) are completely separated as distinct Docker volumes.
* **Database Isolation**: The MySQL instance is shared, but each tenant has a dedicated `DATABASE` and `USER`. The `GRANT` statements restrict Tenant 1 to `tenant1_db.*`. They cannot read `tenant2_db`.

## 2. Secrets Management
**Risk**: Database passwords, salting keys, or API tokens are hardcoded into Git or accessible via logs.
**Mitigation**:
* **Env Vars**: No secrets are stored in Git. Instead, variables like `DB_ROOT_PASSWORD` or `TENANT1_DB_PASSWORD` are passed via external `.env` files (which are in `.gitignore`) or via CI/CD secrets mechanisms.
* **Defaults Fallback**: The provided `docker-compose.yml` uses bash variables with fallbacks `${VAR:-default}` so the local setup works out-of-the-box without exposing production credentials in the repository.

## 3. WordPress-Specific Risks
**Risk**: WordPress is notorious for vulnerable themes and plugins causing supply chain attacks, brute forcing of `wp-login.php`, or XML-RPC attacks.
**Mitigation**:
* **Updates**: Using `wordpress:latest` Docker image means the base image and core WP will receive patches upon container rebuilds.
* **CI Linting**: The added PR pipeline heavily utilizes `wpcs` (WordPress Coding Standards) and `psalm` to detect vulnerabilities (like unescaped output / XSS) before code is ever merged to main.

## 4. CI/CD Supply-Chain Risks
**Risk**: An attacker modifies the GitHub Actions to exfiltrate secrets or injects malware into the build artifact.
**Mitigation**:
* **Pinned Actions**: We use specific action versions (like `actions/checkout@v4`).
* **Artifact Immutability**: Built artifacts are zipped and versioned on tag creation. Deployments fetch these artifacts rather than building on the production servers directly.

## 5. Backup & Recovery Approach
**Risk**: Ransomware encrypts the Docker volumes, or a bad plugin drops a tenant's database tables.
**Mitigation**:
* **Local Strategy**: The Docker volumes (`tenant1_data`, `mysql_data`) persist across container restarts.
* **Production Strategy**: 
  - File backups: Periodic snapshotting of the EFS/Volume backend of the `tenantX_data` volume.
  - DB backups: A cron job running `mysqldump` and uploading to an S3 bucket with versioning and object-locking enabled to prevent deletion.
