variable "container_registry" {
description = "https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry"
  type      = object({
    name                       = string
    location                   = string
    resource_group_name        = string

    admin_enabled     = bool
    sku_name          = string
    ip_white_list     = optional(list(string))
    allow_gha_runners = optional(bool, false)
    
    subnets = optional(list(object({
        name                 = string
        virtual_network_name = string
        resource_group_name  = string
    })))

    registry_scopes = optional(list(object({
      name    = string
      actions = list(string)
    })))

    tags = map(any)
  })
  }
