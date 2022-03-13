# patroni-pgbackrest-demo
Terraform and ansible configuration for deployement of patroni/pgbackrest on GCP

In your ~/.ssh directory create a folder config.d
Add to your ~/.ssh/config.d/ the following line.

`Include ~/.ssh/config.d/*.conf`

# Terraform 
Create a service account for managing the GCP api with the appropiate privileges and generate a key in json format

Add to your .bashrc or .bash_profile (depending on whether you usea login session) the following lines:

```export TF_VAR_HOME=${HOME}
   export TF_VAR_credential_file=<PATH_TO_THE_GCP_JSON_KEY>
   export TF_VAR_gcp_project=<GCP_PROJECT_NAME>
   export TF_VAR_gcp_bucket=<GCP_BUCKET_NAME>
```

initialise terraform with 

`terraform init`

apply the configuration with 


`terraform apply`
# Ansible

Create a service account for accessing the GCP bucket and generate a key in json format

Create a pair of ssh keys without passphrase. This key is deployed on the patroni nodes. 

*DON'T USE YOUR PERSONAL SSH KEY*
## GCP setup 

The make file is expecting the vault's password file in `~/.ansible/patroni_pgbackrest_pwd` .
If the file is missing then it will ask for the password for creating and unlocking the vault.

create a new vault with `make create-vault`


Add the following variables:

* gcp_bucket_credentials: base64 encoded json key file for the service account that need to access the GCP bucket
* ssh_priv_key: base64 encoded ssh private key previously generated
* ssh_pub_key: base64 encoded ssh public key previously generated
* postgres_replica_pwd: Password for the postgresql replicator user
* postgres_su_pwd:  Password for the postgresql super user
* postgres_rewind_pwd:  Password for the postgresql rewind user

