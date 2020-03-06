#variables

variable "subscription_id" {
  description = "subscription id"
}

variable "tenant_id" {
  description = "tenant id"
}

variable "hostname" {
  description = "name of the machine to create"
}

variable "name_prefix" {
  description = "unique part of the name to give to resources"
}

variable "admin_username" {
  description = "VM administrator username"
}

variable "admin_password" {
  description = "VM administrator password"
}

variable "disable_password_authentication" {
  description = "toggle for password auth (recommended to keep disabled)"
  default     = false
}

variable "dockerhub_username" {
  description = "DockerHub Username" 
}
variable "dockerhub_pass" {
  description = "DockerHub Password" 
}

variable "prefix" {
  description = "resource prefix" 
  default = "krassy"
}

