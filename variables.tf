variable "application_name" {
  type        = string
  description = "The name of your application"
  default     = "demo-1542-4281"
}

variable "environment" {
  type        = string
  description = "The environment (dev, test, prod...)"
  default     = ""
}

variable "location" {
  type        = string
  description = "The Azure region where all resources in this example should be created"
  default     = "eastus"
}

variable "azuread_sql_admin" {
  type        = string
  description = "spn or email of azure sql server administrator"
}
