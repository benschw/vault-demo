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

Stand up the `todo` instances:

	./04-provision-todo.sh


Verify everything came up correctly:

	curl -X POST http://172.20.20.14:8080/todo -d '{"status": "new", "content": "Hello World"}'
	curl http://172.20.20.14:8080/todo/1

