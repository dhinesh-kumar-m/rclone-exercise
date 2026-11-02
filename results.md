# Results

## Basic operations

Ran `copy` twice on the same source/destination — the second run
transferred 0 bytes and just did 5 "checks". rclone compares size and
modified time (and checksum where the backend supports it) and skips
anything that already matches.

For `sync`, set up a case where one file was edited after the first
copy, one file was new, and one file existed only at the destination.
`--dry-run` correctly showed 3 files to copy and 1 to delete before
touching anything. Running it for real did exactly that, and
`rclone check` afterward reported 0 differences.

`move` tried a directory-level rename first, then fell back to moving
files one by one since the destination folder already existed. End
result was the same either way — source ends up empty, destination has
the file.

## S3-compatible storage

Created two buckets, uploaded into one, downloaded a subfolder back
out, then copied files from bucket to bucket. That last step logged
`Copied (server-side copy)` for every file — MinIO copied the objects
directly between buckets without the data passing through my machine.
`delete` removed a single object; `purge` wiped a bucket and every
object in it in one go (no undo, so double-check the bucket name).
