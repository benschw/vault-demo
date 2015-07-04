#!/bin/bash
# 02-unseal.sh

VAULT_KEY=$(cat ./vault_key)

echo unseal vault on 172.20.20.11
curl -X PUT http://172.20.20.11:8200/v1/sys/unseal -d '{"secret_shares": 1, "key": "'$VAULT_KEY'"}'
#{"sealed":false,"t":1,"n":1,"progress":0}

echo unseal vault on 172.20.20.12
curl -X PUT http://172.20.20.12:8200/v1/sys/unseal -d '{"secret_shares": 1, "key": "'$VAULT_KEY'"}'
#{"sealed":false,"t":1,"n":1,"progress":0}
