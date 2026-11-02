# File Transfers and Storage Automation with Rclone

DevOps exercise: use rclone to copy, sync and verify files between local
storage and an S3-compatible store (MinIO), without depending on a saved
rclone config file.

## Setup

Start MinIO:

```bash
docker compose up -d
```

Console: http://localhost:9001 (minioadmin / minioadmin123)

Check rclone is installed:

```bash
rclone --version
```

No `rclone.conf` is used anywhere in this repo — credentials and endpoint
are passed via environment variables or CLI flags. See `commands.md` for
the exact approach.

## Files

- `commands.md` — rclone commands used, grouped by topic
- `results.md` — what happened when running them, answers to the exercise questions
- `transfer.sh` — reusable copy/sync script
- `docker-compose.yml` — MinIO setup

## Running transfer.sh

```bash
export RCLONE_S3_PROVIDER=Minio
export RCLONE_S3_ENV_AUTH=false
export RCLONE_S3_ACCESS_KEY_ID=minioadmin
export RCLONE_S3_SECRET_ACCESS_KEY=minioadmin123
export RCLONE_S3_ENDPOINT=http://localhost:9000

./transfer.sh copy ./source-dir ./dest-dir
./transfer.sh sync ./source-dir :s3:testpress-bucket
```
