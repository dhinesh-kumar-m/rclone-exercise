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
