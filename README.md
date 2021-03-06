# patroni-pgbackrest-demo
Terraform and ansible configuration for deployement of patroni/pgbackrest on GCP

In your ~/.ssh directory create a folder config.d
Add to your ~/.ssh/config.d/ the following line.

`Include ~/.ssh/config.d/*.conf`

# Terraform 
Create a service account for managing the GCP api with the appropiate privileges and generate a key in json format

Add to your .bashrc or .bash_profile (depending on whether you usea login session) the following lines:

```
   export TF_VAR_HOME=${HOME}
   export TF_VAR_credential_file=<PATH_TO_THE_GCP_JSON_KEY>
   export TF_VAR_gcp_project=<GCP_PROJECT_NAME>
   export TF_VAR_gcp_bucket=<GCP_BUCKET_NAME>
```

e.g.

```
   export TF_VAR_HOME=${HOME}
   export TF_VAR_credential_file=~/.gcp/idi-patroni-pgbackrest.json
   export TF_VAR_gcp_project=idi-patroni-pgbackrest
   export TF_VAR_gcp_bucket=patroni-pgbackrest-grongo-571
```


initialise terraform with 

`terraform init`

apply the configuration with 


`terraform apply`

# Ansible

**The roles are developed with ansible 5.4.0.**

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

# Check ansible can ping the hosts

cd into the ansible directory and run 

```

make ping-hosts
patroni-1 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
patroni-2 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
patroni-0 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

Then run make all and wait for the playbook to complete.

ssh into a patroni node (e.g. patroni-0) and check patroni is correctly deployed.

```
[ansible@patroni-0 ~]$ sudo -iu postgres
[postgres@patroni-0 ~]$ patronictl -c /etc/patroni/patroni.yml list
+ Cluster: flynn (7074489069180138726) -----+----+-----------+
| Member    | Host      | Role    | State   | TL | Lag in MB |
+-----------+-----------+---------+---------+----+-----------+
| patroni-0 | patroni-0 | Replica | running |  1 |         0 |
| patroni-1 | patroni-1 | Leader  | running |  1 |           |
| patroni-2 | patroni-2 | Replica | running |  1 |         0 |
+-----------+-----------+---------+---------+----+-----------+
 ```

 ## Enable pgbackrest
 Change the variable `patroni_use_pgbackrest: no` to `patroni_use_pgbackrest: yes `

 Then run make configure-patroni

Create the stanza, run a full backup then check the repo status.

```
[postgres@patroni-0 ~]$ pgbackrest --stanza=flynn stanza-create


[postgres@patroni-0 ~]$ pgbackrest --stanza=flynn --type=full backup

[postgres@patroni-0 ~]$ pgbackrest info
stanza: flynn
    status: ok
    cipher: none

    db (current)
        wal archive min/max (14): 000000010000000000000005/000000010000000000000005

        full backup: 20220313-075944F
            timestamp start/stop: 2022-03-13 07:59:44 / 2022-03-13 08:00:33
            wal start/stop: 000000010000000000000005 / 000000010000000000000005
            database size: 25.2MB, database backup size: 25.2MB
            repo1: backup set size: 3.2MB, backup size: 3.2MB


```

