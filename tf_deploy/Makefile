.ONESHELL:
.SHELL := /bin/bash
.PHONY: apply plan init destroy-target
CURRENT_FOLDER=$(shell basename "$$(pwd)")

BOLD=$(shell tput bold)
RED=$(shell tput setaf 1)
GREEN=$(shell tput setaf 2)
YELLOW=$(shell tput setaf 3)
RESET=$(shell tput sgr0)

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

plan: ## Generates a terraform plan
	@terraform plan -var credential_file="${credential_file}" -var gcp_project=${gcp_project}

init: ## Initialise the terraform working dir
	@terraform init -var credential_file="${credential_file}" -var gcp_project=${gcp_project}

apply: ## Applies the terraform infrastructure
	@terraform apply  -var credential_file="${credential_file}" -var gcp_project=${gcp_project}

destroy: ## Destroys the terraform infrastructure
	@terraform destroy   -var credential_file="${credential_file}" -var gcp_project=${gcp_project}

}
