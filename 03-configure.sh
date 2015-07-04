#!/bin/bash
# 03-configure.sh

ROOT_TOKEN=$(cat ./root_token)

echo create 'todo' policy
curl -X POST http://172.20.20.11:8200/v1/sys/policy/todo -H "X-Vault-Token: $ROOT_TOKEN" -d '{"rules":"path \"mysql/creds/todo\" {policy=\"read\"}"}'

echo enable and configure mysql mount
curl -X POST http://172.20.20.11:8200/v1/sys/mounts/mysql -H "X-Vault-Token: $ROOT_TOKEN" -d '{"type": "mysql"}'
curl -X POST http://172.20.20.11:8200/v1/mysql/config/connection -H "X-Vault-Token: $ROOT_TOKEN" -d '{"value": "vaultadmin:vault@tcp(172.20.20.13:3306)/"}'

echo create 'todo' role
curl -X POST http://172.20.20.11:8200/v1/mysql/roles/todo -H "X-Vault-Token: $ROOT_TOKEN" \
	-d '{"sql":"CREATE USER '"'"'{{name}}'"'"'@'"'"'%'"'"' IDENTIFIED BY '"'"'{{password}}'"'"';GRANT ALL ON Todo.* TO '"'"'{{name}}'"'"'@'"'"'%'"'"';"}'


echo enable 'app-id' auth
curl -i -X POST http://172.20.20.11:8200/v1/sys/auth/app-id -H "X-Vault-Token: $ROOT_TOKEN" -d '{"type":"app-id"}'
	
echo add 'todo' app-id
curl -i -X POST http://172.20.20.11:8200/v1/auth/app-id/map/app-id/1a5dea24 -H "X-Vault-Token: $ROOT_TOKEN" -d '{"value": "todo", "display_name": "todo"}'


