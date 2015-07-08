#!/bin/bash
# 04-new-instance.sh

ROOT_TOKEN=$(cat ./root_token)
TODO_APP_ID=0aed7ed3-b576-4f16-99df-82f4ccffccaf

for i in `seq 0 1`; do

	echo "generating 'user_id' for 'todo$i' instance"
	TODO_USER_ID=$(uuidgen)
	curl -X POST http://172.20.20.11:8200/v1/auth/app-id/map/user-id/$TODO_USER_ID -H "X-Vault-Token: $ROOT_TOKEN" \
		-d '{"value": "'$TODO_APP_ID'"}'

	echo "running 'vagrant up todo$i' with newly created 'user_id' passed in as an ENV var"
	VAULT_USER_ID=$TODO_USER_ID vagrant up todo$i
done



