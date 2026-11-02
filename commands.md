# Commands

Running notes on the rclone commands used, grouped by what the exercise asks for.

## 1. Basic file operations

Test data: `source-dir/` (nested folders, text files, a PDF, one 120MB file) copied/synced to `dest-dir/`.

```bash
rclone lsl source-dir                        # list files with size + mtime
rclone copy source-dir dest-dir -P           # copy, never deletes at destination
rclone move move-src move-dst -v             # move (removes from source once copied)
rclone sync source-dir dest-dir --dry-run -v # preview what sync would change
rclone sync source-dir dest-dir -v           # make dest-dir match source-dir exactly
rclone check source-dir dest-dir             # compare two trees, no transfer
```

`copy` only adds or updates files at the destination. `sync` also deletes
anything at the destination that isn't present in the source — always
run it with `--dry-run` first to see what it's about to delete.

## 2. S3-compatible storage (MinIO)

Same commands as above, just pointing at a bucket instead of a folder.
`<s3 flags>` is the block of `--s3-*` flags from section 3 below.

```bash
rclone mkdir :s3:testpress-bucket <s3 flags>                     # create bucket
rclone copy source-dir :s3:testpress-bucket <s3 flags> -P        # upload
rclone copy :s3:testpress-bucket/docs downloaded <s3 flags> -P   # download
rclone lsl :s3:testpress-bucket <s3 flags>                       # list objects
rclone copy :s3:testpress-bucket/docs :s3:testpress-bucket-2/docs <s3 flags> -vv  # bucket to bucket
rclone delete :s3:testpress-bucket-2/docs/sample.pdf <s3 flags>  # delete one object
rclone purge :s3:testpress-bucket-2 <s3 flags>                   # delete bucket + everything in it
```

## 3. Config-free execution (no rclone.conf)

Three ways to pass S3 config without writing a config file. Used
`RCLONE_CONFIG=/dev/null` throughout to make sure nothing was read from
or written to a real config.

**a) On-the-fly connection string** — avoid this one, see results.md.
```bash
rclone lsd ":s3,provider=Minio,env_auth=false,access_key_id=minioadmin,secret_access_key=minioadmin123,endpoint=http://localhost:9000:testpress-bucket"
```

**b) Command-line flags** — this is what `<s3 flags>` means above.
```bash
--s3-provider=Minio --s3-env-auth=false \
--s3-access-key-id=minioadmin --s3-secret-access-key=minioadmin123 \
--s3-endpoint=http://localhost:9000
```

**c) Environment variables** — same options, as env vars instead:
```bash
export RCLONE_S3_PROVIDER=Minio
export RCLONE_S3_ENV_AUTH=false
export RCLONE_S3_ACCESS_KEY_ID=minioadmin
export RCLONE_S3_SECRET_ACCESS_KEY=minioadmin123
export RCLONE_S3_ENDPOINT=http://localhost:9000

rclone mkdir :s3:testpress-bucket
```

## 4. Transfer reliability

```bash
rclone copy source-dir/videos/big-file.bin :s3:testpress-bucket/videos <s3 flags> \
  --transfers=4 --bwlimit=50M --stats=2s -P
```

- `--transfers` — how many files move in parallel.
- `--bwlimit` — hard cap on bandwidth, e.g. `50M` = 50 MiB/s.
- `--stats` — how often to print a progress summary.
- `--retries` / `--low-level-retries` — how many times to retry a failed
  file / a failed HTTP request before giving up.

To test an interruption: started a copy of 2 small files + a 1GB file
with `--transfers=1`, killed the rclone process a few seconds in, then
ran the exact same command again.

## 5. Sync safety

```bash
rclone sync source-dir dest-dir --dry-run -v   # always run this first
rclone sync source-dir dest-dir -v             # then the real sync
rclone check source-dir dest-dir               # verify after
```

`--dry-run` costs nothing and shows exactly what would be copied and
deleted. `check` just compares — it never changes anything, so it's
safe to run any time you want to confirm two trees actually match.
