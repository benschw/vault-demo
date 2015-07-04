
	./deps.sh
	vagrant up infra

	vagrant ssh infra
	export VAULT_ADDR='http://172.20.20.10:8200'
	export VAULT_ADDR='http://127.0.0.1:8200'
	vault init
	Key 1: ed5188e6a92c26f394b421dc2bc5790c82eb257db613fb5dc94cc259ac618f5401
	Key 2: 10d8fd02c00c6d8b1a64b08c4256edaec10f4d936e05277ec9114b1307a20f3f02
	Key 3: 424f3b9ae2c736fa06f5fad3e27dfc101065af9d0e0e1b32798b80477650e8f003
	Initial Root Token: 59012fc4-e665-0f34-56cb-7ecc8cda8b1a

	vault unseal # times 3
	vault auth <root-token>

	vault mount mysql
	vault write mysql/config/connection value="root:root@tcp(172.20.20.13:3306)/"
	vault write mysql/config/connection value="vaultadmin:vault@tcp(172.20.20.13:3306)/"

	vault write mysql/roles/todo sql="CREATE USER '{{name}}'@'%' IDENTIFIED BY '{{password}}';GRANT ALL ON Todo.* TO '{{name}}'@'%';"
	#test it out
	vault read mysql/creds/todo

	vault policy-write todo /vagrant/todo-policy.hcl

	vault auth-enable app-id
	vault write auth/app-id/map/app-id/1a5dea24-7a0f-4416-b61f-a13439ba2317 value=todo display_name=todo
	vault write auth/app-id/map/user-id/657a0247-0f7e-4fc7-8996-1445af21597e value=1a5dea24-7a0f-4416-b61f-a13439ba2317

	curl --silent --data '{"app_id": "1a5dea24-7a0f-4416-b61f-a13439ba2317", "user_id": "657a0247-0f7e-4fc7-8996-1445af21597e"}' "$VAULT_ADDR/v1/auth/app-id/login"

	
	export VAULT_ADDR='http://127.0.0.1:8200'
	export VAULT_APP_ID='1a5dea24-7a0f-4416-b61f-a13439ba2317'
	export VAULT_USER_ID='657a0247-0f7e-4fc7-8996-1445af21597e'


	curl -X PUT http://172.20.20.11:8200/v1/sys/init -d '{"secret_shares": 1, "secret_threshold": 1}'
	{"keys":["39c7a7c3e8340f42d4f58bf57598037c1293b2b3525aa41fa64624fdc7d980a6"],"root_token":"dc3f7bc7-6dee-a636-06b9-3a9c88c3dfa7"}
	
	curl -X PUT http://172.20.20.11:8200/v1/sys/unseal -d '{"secret_shares": 1, "key": "39c7a7c3e8340f42d4f58bf57598037c1293b2b3525aa41fa64624fdc7d980a6"}'                                                                                                                                                     │0 packages can be updated.
	{"sealed":false,"t":1,"n":1,"progress":0}

	curl -X POST http://172.20.20.11:8200/v1/sys/mounts/mysql -H "X-Vault-Token: dc3f7bc7-6dee-a636-06b9-3a9c88c3dfa7" -d '{"type": "mysql"}
	curl -X POST http://172.20.20.11:8200/v1/mysql/config/connection -H "X-Vault-Token: dc3f7bc7-6dee-a636-06b9-3a9c88c3dfa7" -d '{"value": "vaultadmin:vault@tcp(172.20.20.13:3306)/"}'

	curl -X POST http://172.20.20.11:8200/v1/mysql/roles/todo -H "X-Vault-Token: dc3f7bc7-6dee-a636-06b9-3a9c88c3dfa7"
		'{"sql": "CREATE USER '"'"'{{name}}'"'"'@'"'"'%'"'"' IDENTIFIED BY '"'"'{{password}}'"'"';GRANT ALL ON Todo.* TO '"'"'{{name}}'"'"'@'"'"'%'"'"';"}'
	curl -X POST http://172.20.20.11:8200/v1/sys/policy/todo -H "X-Vault-Token: dc3f7bc7-6dee-a636-06b9-3a9c88c3dfa7" -d '{"rules":"path \"mysql/creds/todo\" {policy=\"read\"}"}'

	# enable app-id auth
	curl -i -X POST http://172.20.20.11:8200/v1/sys/auth/app-id -H "X-Vault-Token: dc3f7bc7-6dee-a636-06b9-3a9c88c3dfa7" -d '{"type":"app-id"}'
	
	# add todo app-id
	curl -i -X POST http://172.20.20.11:8200/v1/auth/app-id/map/app-id/1a5dea24 -H "X-Vault-Token: dc3f7bc7-6dee-a636-06b9-3a9c88c3dfa7" -d '{"value": "todo", "display_name": "todo"}'

	# add new user for todo app-id
	curl -i -X POST http://172.20.20.11:8200/v1/auth/app-id/map/user-id/657a0247 -H "X-Vault-Token: dc3f7bc7-6dee-a636-06b9-3a9c88c3dfa7" -d '{"value": "1a5dea24"}'
	

	export VAULT_ADDR='http://172.20.20.10:8200'
	export VAULT_APP_ID='1a5dea24'
	export VAULT_USER_ID='657a0247'




	curl -X POST http://172.20.20.14:8080/todo -d '{"status": "new", "content": "Hello World"}'
	curl http://172.20.20.14:8080/todo/1



