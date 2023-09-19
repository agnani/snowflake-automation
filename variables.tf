# Azure Creds

variable "subscription_id" {
  type = string
}
variable "client_id" {
  type = string
}
variable "client_secret" {
  type = string
}
variable "tenant_id" {
  type = string
}

# Snowflake Creds

variable "username" {
  type = string
}
variable "password" {
  type = string
}
variable "account" {
  type = string
}

# Azure 

variable "name" {
  type = string
}
variable "admin_username" {
  type = string
}
variable "admin_password" {
  type = string
}
variable "computer_name" {
  type = string
}
variable "location" {
  type = string
}
variable "disk_size_gb" {
  type = string
}
variable "VM_machine_size" {
  type = string
}
variable "use_static_ip" {
  type = bool
}
variable "VM_public_ip_name" {
  type = string
}
variable "VM_public_ip_rg" {
  type = string
}

# Snowflake

variable "email" {
  type = string
}
variable "first_name" {
  type = string
}
variable "last_name" {
  type = string
}
variable "must_change_password" {
  type = bool
}
variable "edition" {
  type = string
}
variable "comment" {
  type = string
}
variable "region" {
  type = string
}