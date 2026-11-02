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
