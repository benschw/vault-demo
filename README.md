
	./deps.sh
	vagrant up infra

	vagrant ssh infra
	export VAULT_ADDR='http://127.0.0.1:8200'
	vault init
	Key 1: ed5188e6a92c26f394b421dc2bc5790c82eb257db613fb5dc94cc259ac618f5401
	Key 2: 10d8fd02c00c6d8b1a64b08c4256edaec10f4d936e05277ec9114b1307a20f3f02
	Key 3: 424f3b9ae2c736fa06f5fad3e27dfc101065af9d0e0e1b32798b80477650e8f003
	Initial Root Token: 59012fc4-e665-0f34-56cb-7ecc8cda8b1a

	vault unseal # times 3
	vault auth <root-token>

	vault mount mysql
	vault write mysql/config/connection value="root:root@tcp(127.0.0.1:3306)/"

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
