## POC Vault cluster

### 6 vms

- `consul` consul server to coordinate discovery and provide a backend for vault
- `vault0` vault server
- `vault1` a second vault server to demonstrate how HA works
- `mysql` a mysql-server for the todo service to utilize. credentials are managed by vault
- `todo0` the demo service to see everything come together
- `todo1` a second demo service for HA

### not just a simple `vagrant up`:
For vault to be secure, the bootstrapping process for a new vault server must be done out of band.
Key shards must be provided to unseal the vault, and these should be entrusted to trusted people
(by entrusting them to an automated process, you haven't secured anything - just added
[another turtle](https://en.wikipedia.org/wiki/Turtles_all_the_way_down) to the stack).

That said, for this POC we are automating it (but keeping the work separate from the normal
automation to illustrate the separation). So that's what all the bash scripts coming up are all about.


### Setup

Install puppet deps:

	./puppet-deps.sh


Bring up the infrastructure:

	vagrant up consul vault0 vault1 mysql

Initialize, Unseal, and configure Vault:

	./01-init.sh
	./02-unseal.sh
	./03-configure.sh

Stand up the `todo` instance:

	./04-provision-todo.sh


Verify everything came up correctly:

	curl -X POST http://172.20.20.14:8080/todo -d '{"status": "new", "content": "Hello World"}'
	curl http://172.20.20.14:8080/todo/1

### notes

	export VAULT_ADDR='http://127.0.0.1:8200'
	export VAULT_APP_ID='1a5dea24-7a0f-4416-b61f-a13439ba2317'
	export VAULT_USER_ID='657a0247-0f7e-4fc7-8996-1445af21597e'


### cli notes

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

	curl -X POST "$VAULT_ADDR/v1/auth/app-id/login" -d '{"app_id": "1a5dea24-7a0f-4416-b61f-a13439ba2317", "user_id": "657a0247-0f7e-4fc7-8996-1445af21597e"}'



