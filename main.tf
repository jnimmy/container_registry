locals {
   ip_rules = var.container_registry.allow_gha_runners == true ? concat(module.meta[0].azure_gha_nat_cidrs, module.meta[0].mercedes_benz_proxy_networks, var.container_registry.ip_white_list) : var.container_registry.ip_white_list
   subnets  = var.container_registry.allow_gha_runners == true ? concat(module.meta[0].azure_gha_subnet_ids, [for item in data.azurerm_subnet.subnets : item.id]) : [for item in data.azurerm_subnet.subnets : item.id]
}

module "meta" {
   count = var.container_registry.allow_gha_runners == true ? 1 : 0

   source = "git::git@git.i.mercedes-benz.com:terraform/azure-gb4-meta.git"
}

data "azurerm_subnet" "subnets" {
  for_each  = var.container_registry.subnets != null ? {
    for index, subnet in var.container_registry.subnets:
    subnet.name => subnet
  } : {}

  name                 = each.value.name
  virtual_network_name = each.value.virtual_network_name
  resource_group_name  = each.value.resource_group_name
}

resource "azurerm_container_registry" "container_registry" {
   name                = var.container_registry.name
   resource_group_name = var.container_registry.resource_group_name
   location            = var.container_registry.location
       
   sku           = var.container_registry.sku_name
   admin_enabled = var.container_registry.admin_enabled

   network_rule_set {
      default_action = "Deny"

      ip_rule = [for ip in local.ip_rules : {
         action   = "Allow"
         ip_range = ip
      }]

      virtual_network = [for subnet_id in local.subnets : {
         action    = "Allow"
         subnet_id = subnet_id
      }]
   }

   tags = var.container_registry.tags
}

resource "azurerm_container_registry_scope_map" "scope_map" {
   for_each  = var.container_registry.registry_scopes != null ? {
      for index, scope_map in var.container_registry.registry_scopes:
      scope_map.name => scope_map
   } : {}

   name                    = each.value.name
   container_registry_name = azurerm_container_registry.container_registry.name
   resource_group_name     = var.container_registry.resource_group_name
   actions                 = each.value.actions
}

resource "azurerm_container_registry_token" "token" {
   for_each = azurerm_container_registry_scope_map.scope_map

   name                    = "${each.value.name}-token"
   container_registry_name = azurerm_container_registry.container_registry.name
   resource_group_name     = var.container_registry.resource_group_name
   scope_map_id            = each.value.id
}