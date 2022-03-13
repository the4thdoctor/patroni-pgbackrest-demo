#
#
#
.ONESHELL:
.SHELL := /bin/bash
.PHONY: remove-temporary-password
CURRENT_FOLDER=$(shell basename "$$(pwd)")
BOLD=$(shell tput bold)
RED=$(shell tput setaf 1)
GREEN=$(shell tput setaf 2)
YELLOW=$(shell tput setaf 3)
RESET=$(shell tput sgr0)
extra ?= "-e 'makefile=true' -v"
ansible_user ?= "ansible"
vault_pwd_file ?= ~/.ansible/patroni_pgbackrest_pwd
vault_all_file ?= inventory/gcp/group_vars/all/vault.yml
ifndef vault_id_pwd
	ifneq ("$(wildcard $(vault_pwd_file))","")
    	vault_pwd = "--vault-password-file=${vault_pwd_file}"
	else
		vault_pwd = "--ask-vault-pass"
	endif
endif
ifdef vault_id_pwd
$(shell echo "${vault_id_pwd}" > ${vault_temporary_pwd_file})
	vault_pwd = "--vault-password-file=${vault_temporary_pwd_file}"
endif


help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

ping-hosts: ## Ping the hosts
	@ansible ${vault_pwd} -u ${ansible_user} -i inventory/gcp/hosts --diff -m ping hosts $(extra)

all: ## Configures the machines applying in sequence all roles
	@ansible-playbook ${vault_pwd} -u ${ansible_user} -i inventory/gcp/hosts --diff playbooks/setup_all.yml $(extra)

configure-patroni: ## Reconfigures patroni according with the inventory
	@ansible-playbook ${vault_pwd} -u ${ansible_user} -i inventory/gcp/hosts -e configure_patroni=yes --diff playbooks/setup_patroni.yml $(extra)

postgres: ## Deploys the hosts file on the hosts
	@ansible-playbook ${vault_pwd} -u ${ansible_user} -i inventory/gcp/hosts --diff playbooks/setup_postgres.yml $(extra)

etcd: ## Configures etcd
	@ansible-playbook ${vault_pwd} -u ${ansible_user} -i inventory/gcp/hosts --diff playbooks/setup_etcd.yml $(extra)

patroni: ## Configures patroni
	@ansible-playbook ${vault_pwd} -u ${ansible_user} -i inventory/gcp/hosts --diff playbooks/setup_patroni.yml $(extra)

pgbackrest: ## Configures pgbackrest
	@ansible-playbook ${vault_pwd} -u ${ansible_user} -i inventory/gcp/hosts --diff playbooks/setup_pgbackrest.yml $(extra)

create-vault: ## Create a new vault file in gcp/group_vars/all/vault.yml
	@ansible-vault create ${vault_pwd}  ${vault_all_file}

edit-vault: ## Edit the vault file stored in gcp/group_vars/all/vault.yml
	@ansible-vault edit ${vault_pwd}  ${vault_all_file}

rekey-vault: ## Change the vault encryption key
	@ansible-vault rekey ${vault_pwd}  ${vault_all_file}