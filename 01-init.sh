#!/bin/bash
# 01-init.sh

echo initialize vault
INIT_RESP=$(curl -s -X PUT http://172.20.20.11:8200/v1/sys/init -d '{"secret_shares": 1, "secret_threshold": 1}')
#{"keys":["39c7a7c3e8340f42d4f58bf57598037c1293b2b3525aa41fa64624fdc7d980a6"],"root_token":"dc3f7bc7-6dee-a636-06b9-3a9c88c3dfa7"}
ROOT_TOKEN=$(echo $INIT_RESP | jq .root_token | sed -e 's/^"//'  -e 's/"$//')
VAULT_KEY=$(echo $INIT_RESP | jq .keys[0] | sed -e 's/^"//'  -e 's/"$//')

echo write files 'vault_key' and 'root_token'
echo -e $ROOT_TOKEN > ./root_token
echo -e $VAULT_KEY > ./vault_key

