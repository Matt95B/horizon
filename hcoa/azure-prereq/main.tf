# Horizon Cloud NextGen on Azure pre-requisites deployment via Terraform.

# Variables from 'terraform.tfvars'
variable "azure" {
    type = map(string)
}
variable "resource_group" {
    type = map(string)
}
variable "vnet" {
    type = map(string)
}
variable "management_subnet" {
    type = map(string)
}
variable "dmz_subnet" {
    type = map(string)
}
variable "desktop_subnet" {
    type = map(string)
}
variable "dns_servers" {
    type = list(string)
}
variable "connectivity_type" {
    type = string
}
variable "nat_gateway" {
    type = map(string)
}
variable "azure_public_ip" {
    type = map(string)
}
variable "route_table" {
    type = map(string)
}
variable "identities" {
    type = map(string)
}
variable "service_principal_roles" {
    type = list(string)
}
variable "compute_read_only_roles" {
    type = list(string)
}

# Configure the Azure Resource Manager Provider
terraform {
  required_providers { 
          azurerm = { 
              source  = "hashicorp/azurerm"
              version = "~> 4.0.0"
          }
          azuread = {
              source  = "hashicorp/azuread"
              version = "~> 3.0.0"
          }
      }
}
provider "azurerm" { 
    features { 
        resource_group { 
            prevent_deletion_if_contains_resources = false 
        } 
    }
    subscription_id         = var.azure.subscription_id
    tenant_id               = var.azure.tenant_id
    resource_provider_registrations = "none"
}

provider "azuread" {}

# Create a Resource Group
resource "azurerm_resource_group" "resource_group" {
    name                    = var.resource_group.name
    location                = var.resource_group.deployment_location
}

# Create a Virtual Network
resource "azurerm_virtual_network" "vnet" {
    name                    = var.vnet.name
    location                = var.resource_group.deployment_location
    resource_group_name     = azurerm_resource_group.resource_group.name
    address_space           = [var.vnet.address_space]
    dns_servers             = var.dns_servers
}

# Create the Management Subnet
resource "azurerm_subnet" "management_subnet" {
    name                 = var.management_subnet.name
    resource_group_name  = azurerm_resource_group.resource_group.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes     = [var.management_subnet.address_prefix]
}

# Create the DMZ Subnet
resource "azurerm_subnet" "dmz_subnet" {
    name                 = var.dmz_subnet.name
    resource_group_name  = azurerm_resource_group.resource_group.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes     = [var.dmz_subnet.address_prefix]
}

# Create the Desktop Subnet
resource "azurerm_subnet" "desktop_subnet" {
    name                 = var.desktop_subnet.name
    resource_group_name  = azurerm_resource_group.resource_group.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes     = [var.desktop_subnet.address_prefix]
}

# Create a Public IP, if NAT is selected
resource "azurerm_public_ip" "public_ip" {
    count                   = var.connectivity_type == "NAT" ? 1 : 0
    name                    = var.azure_public_ip.ip_name
    resource_group_name     = azurerm_resource_group.resource_group.name
    location                = var.resource_group.deployment_location
    allocation_method       = var.azure_public_ip.ip_allocation
    sku                     = var.azure_public_ip.ip_sku
}

# Create a NAT Gateway, if NAT is selected
resource "azurerm_nat_gateway" "nat_gateway" {
    count                   = var.connectivity_type == "NAT" ? 1 : 0
    name                    = var.nat_gateway.name
    location                = var.resource_group.deployment_location
    resource_group_name     = azurerm_resource_group.resource_group.name
    sku_name                = var.nat_gateway.sku_name
}

# Associate a Public IP to the NAT Gateway, if NAT is selected
resource "azurerm_nat_gateway_public_ip_association" "public_ip_association" { 
    count                   = var.connectivity_type == "NAT" ? 1 : 0
    nat_gateway_id          = azurerm_nat_gateway.nat_gateway[count.index].id
    public_ip_address_id    = azurerm_public_ip.public_ip[count.index].id
}

# Associate the Management Subnet to the NAT Gateway, if NAT is selected
resource "azurerm_subnet_nat_gateway_association" "mgmt_subnet_nat_gateway_association" {
    count                   = var.connectivity_type == "NAT" ? 1 : 0
    subnet_id               = azurerm_subnet.management_subnet.id
    nat_gateway_id          = azurerm_nat_gateway.nat_gateway[count.index].id
}

# Create user defined route table, if Route is selected
resource "azurerm_route_table" "route_table" {
  count                         = var.connectivity_type == "Route" ? 1 : 0
  name                          = var.route_table.name
  location                      = var.resource_group.deployment_location
  resource_group_name           = azurerm_resource_group.resource_group.name

  route {
    name           = var.route_table.route_name
    address_prefix = var.route_table.address_prefix
    next_hop_type  = var.route_table.next_hop_type
  }
}

# Associate user defined route table to the management subnet, if Route is selected
resource "azurerm_subnet_route_table_association" "route_table_sub_association" {
  count          = var.connectivity_type == "Route" ? 1 : 0
  subnet_id      = azurerm_subnet.management_subnet.id
  route_table_id = azurerm_route_table.route_table[count.index].id
}

# Create Managed Identity
resource "azurerm_user_assigned_identity" "managed_identity" {
    name                    = var.identities.managed_identity_name
    location                = var.resource_group.deployment_location
    resource_group_name     = azurerm_resource_group.resource_group.name
}

# Assign the Managed Identity Roles
resource "azurerm_role_assignment" "assign_identity_network_contributor" {
    scope                = "/subscriptions/${var.azure.subscription_id}"
    role_definition_name = "Network Contributor"
    principal_id         = azurerm_user_assigned_identity.managed_identity.principal_id
}
resource "azurerm_role_assignment" "assign_identity_managed_identity_operator" {
    scope                = "/subscriptions/${var.azure.subscription_id}"
    role_definition_name = "Managed Identity Operator"
    principal_id         = azurerm_user_assigned_identity.managed_identity.principal_id
}

# Create Custom Service Principal Role
resource "azurerm_role_definition" "service_principal_role" {
    name                    = var.identities.service_principal_role_name
    description             = var.identities.service_principal_role_description
    scope                   = "/subscriptions/${var.azure.subscription_id}"
    permissions {
        actions             = var.service_principal_roles
        not_actions         = []
    }
}

# Create Custom Compute Gallery Read-Only Role
resource "azurerm_role_definition" "compute_read_only_role" {
    name                    = var.identities.compute_ro_role_name
    description             = var.identities.compute_ro_role_description
    scope                   = "/subscriptions/${var.azure.subscription_id}"
    permissions {
        actions             = var.compute_read_only_roles
        not_actions         = []
    }
}

# Create Service Principal
data "azuread_client_config" "current" {}

resource "azuread_application" "ent_application" {
    display_name    = var.identities.service_principal_name
    owners          = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal" "service_principal" {
    client_id                       = azuread_application.ent_application.client_id
    app_role_assignment_required    = false
    owners                          = [data.azuread_client_config.current.object_id]
}

# Create Service Principal Password
resource "azuread_application_password" "service_principal_password" {
    display_name        = var.identities.service_principal_secret_name
    application_id      = azuread_application.ent_application.id
    end_date            = timeadd(timestamp(), var.identities.service_principal_secret_expiry)
}

# Assign the Service Principal Roles
resource "azurerm_role_assignment" "assign_service_principal_role" {
    scope                = "/subscriptions/${var.azure.subscription_id}"
    role_definition_name = azurerm_role_definition.service_principal_role.name
    principal_id         = azuread_service_principal.service_principal.object_id
}
resource "azurerm_role_assignment" "assign_compute_read_only_role" {
    scope                = "/subscriptions/${var.azure.subscription_id}"
    role_definition_name = azurerm_role_definition.compute_read_only_role.name
    principal_id         = azuread_service_principal.service_principal.object_id
}

# Configuration output needed to build the Horizon Edge
output "subscription_id" {
    value = var.azure.subscription_id
}

output "tenant_id" {
    value = var.azure.tenant_id
}

output "service_principal_client_id" {
    value = azuread_service_principal.service_principal.client_id
}

output "service_principal_pwd_id" {
    value     = azuread_application_password.service_principal_password.key_id
    sensitive = true
}

output "service_principal_pwd_key" {
    value     = azuread_application_password.service_principal_password.value
    sensitive = true
}

output "service_principal_pwd_key_expiry" {
    value     = azuread_application_password.service_principal_password.end_date
}

output "managed_identity_client_id" {
    value = azurerm_user_assigned_identity.managed_identity.client_id
}