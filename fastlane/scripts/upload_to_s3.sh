#!/bin/bash

set -euo pipefail

LOCAL_FILE="$1"
S3_DEST="$2"

if [[ -z "$LOCAL_FILE" || -z "$S3_DEST" ]]; then
  echo "Usage: $0 <local_file_path> <s3_bucket_path>"
  exit 1
fi

echo "Uploading: $LOCAL_FILE → s3://$S3_DEST"
aws s3 cp "$LOCAL_FILE" "s3://$S3_DEST"