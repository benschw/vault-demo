
	./deps.sh
	vagrant up infra

	vagrant ssh infra
	export VAULT_ADDR='http://127.0.0.1:8200'
	vault init
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
	vault write auth/app-id/map/user-id/657a0247-0f7e-4fc7-8996-1445af21597e value=foo cidr_block=172.20.0.0/16
