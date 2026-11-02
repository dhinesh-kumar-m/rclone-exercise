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
