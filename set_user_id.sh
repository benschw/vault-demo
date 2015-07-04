#!/bin/bash

mkdir -p /etc/vault
echo export VAULT_USER_ID=$1 > /etc/vault/user_id
