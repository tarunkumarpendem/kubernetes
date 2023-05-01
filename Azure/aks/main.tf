resource "azurerm_resource_group" "rsg_prod" {
    count = length(var.resource_group_details.resource_group_name)
    name = var.resource_group_details.resource_group_name
    location = var.resource_group_details.location
    tags = {
      "Name" = var.resource_group_details.resource_group_tags[0]
      "ENV"  = var.resource_group_details.resource_group_tags[1]
    }
}


resource "azurerm_virtual_network" "aks_vnet" {
    count = length(var.network_details.vnet_name)
    resource_group_name = azurerm_resource_group.rsg_prod.name
    location = var.resource_group_details.location
    name = var.network_details.vnet_name
    address_space = [ var.network_details.vnet_address_space ]
    tags = {
      "Name" = ""
      "ENV"  = ""
    }
    ddos_protection_plan {
      
    }
}


resource "azurerm_subnet" "aks_vnet_subnet_1" {
    name = ""
    virtual_network_name = azurerm_virtual_network.aks_vnet.name
    resource_group_name = azurerm_resource_group.rsg_prod.name
    address_prefixes = [ "value" ]
    service_endpoints = [ "value" ] 
}


resource "azurerm_network_security_group" "sg_aks" {
    name = ""
    location = ""
    resource_group_name = ""
    tags = {
      "Name" = ""
      "ENV"  = ""
      "vnet" = ""
    } 
}

resource "azurerm_network_security_rule" "SSH" {
    name = ""
    resource_group_name = azurerm_resource_group.rsg_prod.name
    network_security_group_name = azurerm_network_security_group.sg_aks.name
    description = ""
    protocol = ""
    source_port_ranges = [ "value" ]
    destination_port_ranges = [ "value" ]
    source_address_prefixes = [ "value" ]
    destination_address_prefixes = [ "value" ]
    access = ""
    priority = ""
    direction = ""
}

resource "azurerm_private_dns_zone" "dns_zone" {
  name                = ""
  resource_group_name = azurerm_resource_group.rsg_prod.name
}


resource "azurerm_user_assigned_identity" "user_identity" {
  name                = ""
  resource_group_name = azurerm_resource_group.rsg_prod.name
  location            = ""
}

resource "azurerm_role_assignment" "role_assign" {
  scope                = azurerm_private_dns_zone.dns_zone.id
  role_definition_name = "Private DNS Zone Contributor"
  principal_id         = azurerm_user_assigned_identity.user_identity.id
}

resource "azurerm_kubernetes_cluster" "aks_prod" {
    name = ""
    location = ""
    resource_group_name = azurerm_resource_group.rsg_prod.name
    dns_prefix = ""
    kubernetes_version = ""
    private_cluster_enabled = true
    private_dns_zone_id = azurerm_private_dns_zone.dns_zone.id
    default_node_pool {
      name = ""
      node_count = ""
      vm_size = ""
      vnet_subnet_id = ""
      enable_auto_scaling = ""
      availability_zones  = ""
      min_count           = ""
      max_count           = ""
      max_pods            = ""
      node_labels         = ""
      node_taints         = ""
      os_disk_size_gb     = ""
      os_disk_type        = ""
    }
    identity {
      type = ""
    }
    service_principal {
      client_id = ""
      client_secret = ""
    }
    linux_profile {
      admin_username = ""
      ssh_key {
        key_data = ""
      }
    }
    role_based_access_control_enabled = {
        enabled = ""
    }
    tags = {
      "Name" = ""
      "ENV"  = ""
    }
    network_profile {
        network_plugin = "kubenet"
        service_cidr = ""
        pod_cidr = ""
        dns_service_ip = ""
        docker_bridge_cidr = ""
    }
    sku_tier = ""
    storage_profile {
      disk_driver_version = ""
      disk_driver_enabled = ""
      blob_driver_enabled = ""
      file_driver_enabled = ""
      snapshot_controller_enabled = ""
    }
}