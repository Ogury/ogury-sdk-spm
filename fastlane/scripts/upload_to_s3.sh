#!/bin/bash
set -e

CREDS=$(aws sts assume-role \
  --role-arn arn:aws:iam::556593845588:role/ci-eu-west-1-macos-jenkins-ci \
  --role-session-name fastlane-upload-session)

export AWS_ACCESS_KEY_ID=$(echo "$CREDS" | jq -r '.Credentials.AccessKeyId')
export AWS_SECRET_ACCESS_KEY=$(echo "$CREDS" | jq -r '.Credentials.SecretAccessKey')
export AWS_SESSION_TOKEN=$(echo "$CREDS" | jq -r '.Credentials.SessionToken')

echo "Uploading from: $1 to s3://$2/"
aws s3 cp "$1" "s3://$2/"