
	./deps.sh
	vagrant up infra

	vagrant ssh infra
	export VAULT_ADDR='http://127.0.0.1:8200'
	vault init
	vault unseal
