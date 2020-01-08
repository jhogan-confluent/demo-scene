###########################################
################## AWS ####################
###########################################

provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region = local.region
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "random_string" "random_string" {
  length = 8
  special = false
  upper = false
  lower = true
  number = false
}

data "aws_s3_bucket" "pacman" {
  bucket = var.aws_pacman_bucket_name
}

variable "aws_access_key" {
}

variable "aws_secret_key" {
}

variable "aws_pacman_bucket_name" {
}

###########################################
############# Confluent Cloud #############
###########################################

variable "bootstrap_server" {
}

variable "cluster_api_key" {
}

variable "cluster_api_secret" {
}

variable "schema_registry_url" {
}

variable "schema_registry_basic_auth" {
}

locals {
  region = split(".", var.bootstrap_server)[1]
}

###########################################
################## Others #################
###########################################

variable "global_prefix" {
  default = "pacman-ccloud"
}

variable "ksqldb_server_image" {
  default = "confluentinc/ksqldb-server"
}
