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

## Config-free execution

The on-the-fly connection string (`:s3,param=value,...:bucket`) broke
for me: the endpoint `http://localhost:9000` has a colon in it, and the
connection string also uses colons to separate config from the bucket
path. rclone either threw a mangled-URL error or just hung, depending
on exactly how I wrote it. Couldn't find a clean escape for this in
rclone 1.65.2, so I'd skip this style for any endpoint with a port
number — which is basically every self-hosted MinIO.

Command-line flags and environment variables both worked every time,
no issues. Checked `~/.config/rclone/rclone.conf` never got created —
every command printed the "config file not found, using defaults"
notice, confirming nothing was ever read from or written to disk.

**For production I'd use environment variables.** Most secrets tooling
(Vault, k8s secrets, systemd `EnvironmentFile`, Celery worker env) is
already built to inject env vars into a process, so the actual rclone
command stays credential-free and safe to put in a script or repo.
CLI flags work too but put the secret in the command line itself,
which can leak into `ps aux` or shell history.
