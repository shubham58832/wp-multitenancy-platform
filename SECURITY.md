# Security Notes

A few notes on how this platform is secured:

- **Isolation**: Each tenant runs in its own container. DB is shared but logic/privileges are separated (tenant1 cannot read tenant2_db).
- **Secrets**: Put passwords in `.env`. Don't commit `.env` to git (it's in `.gitignore`).
- **Updates**: We use `wordpress:latest` so containers rebuild with the newest core version.
- **CI Checks**: Github Actions run `phpcs` and `psalm` to catch basic vulnerabilities before merges.
- **Backups**: Docker volumes persist data locally. In production, we'll need to cron `mysqldump` and ship backups to S3.
