output "container_registry_name" {
    description = "The name of the Container Registry"
    value = azurerm_container_registry.container_registry.name
}

output "container_registry_id" {
  description = "The ID of the Container Registry"
  value       = azurerm_container_registry.container_registry.id
}