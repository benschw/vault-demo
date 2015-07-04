#!/bin/bash
# 04-new-instance.sh

ROOT_TOKEN=$(cat ./root_token)


UUID=$(uuidgen)
# add new user for `todo` app-id
curl -i -X POST http://172.20.20.11:8200/v1/auth/app-id/map/user-id/$UUID -H "X-Vault-Token: $ROOT_TOKEN" -d '{"value": "1a5dea24"}'

VAULT_USER_ID=$UUID vagrant up demo 

#export VAULT_ADDR='http://172.20.20.10:8200'
#export VAULT_APP_ID='1a5dea24'
#export VAULT_USER_ID='657a0247'

