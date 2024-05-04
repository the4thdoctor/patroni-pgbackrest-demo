variable "HOME" {
    type        = string
    description = "This is local user HOME DIR, if not recognised you will need to export the variable TF_VAR_HOME set to your home dir "
}

variable "credential_file" {
    type        = string
    description = "The credential file with full path specs."
}

variable "gcp_project" {
    type        = string
    description = "The gcp project's name. Set the variable."
}

variable "patroni_node_count" {
  default = "3"
  description = "Number of fds nodes"
  }

variable "ssh_user" {
  default = "ansible"
  description = "ssh ansible user"
}

variable "ssh_key" {
  default = ".ssh/patroni-pgbackrest"
  description = "ssh key for login"
}

variable "ssh_conf" {
  default = ".ssh/config.d/patroni_pgbackrest.conf"
  description = "ssh configuration file"
}

variable "node_prefix" {
    default = "patroni-"
    description = "The node name prefix"
}

variable "gcp_region" {
    default = "europe-west4"
    description = "The region to use"
}

variable "gcp_zone" {
    default = "a"
    description = "The availability zone to use"
}

variable "gcp_bucket" {
  type        = string
  description = "ssh key for login"
}
