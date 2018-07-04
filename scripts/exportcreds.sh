#!/bin/bash
profile=tse

# make sure we have a token
echo "Requesting identity with profile $profile"
aws sts get-caller-identity --profile $profile

cachedir=~/.aws/cli/cache
creds_json=$(cat $cachedir/*json)

AWS_ACCESS_KEY_ID=$(echo "$creds_json" | jq -r .Credentials.AccessKeyId)
AWS_SECRET_ACCESS_KEY=$(echo "$creds_json" | jq -r .Credentials.SecretAccessKey)
AWS_SESSION_TOKEN=$(echo "$creds_json"  | jq -r .Credentials.SessionToken)

echo exporting AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_SESSION_TOKEN
export AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN

exp=$(echo "$creds_json" | jq -r .Credentials.Expiration)
echo "Current token expires at: $exp"
