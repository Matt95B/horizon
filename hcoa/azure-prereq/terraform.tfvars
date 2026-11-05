# Edit the below variables for your Horizon Cloud deployment to suit your environment.

# Provide the ID of the Subscription in Azure you want to deploy against.
# Provide the Tenant ID of your Entra ID tenant
azure = {
  subscription_id = "xxxx-xxxx-xxxx-xxxx-xxxx"
  tenant_id = "yyyy-yyyy-yyyy-yyyy-yyyy"
}

# Resource group and region you want to deploy Horizon Cloud
resource_group = {
  name = "rg-HCoA"
  deployment_location = "australiaeast"
}

# Azure virtual network (vnet) and address space
vnet = {
  name = "vnet-HCoA",                                   
  address_space = "x.x.x.x/x"
}

# Horizon Cloud management subnet, /26 minimum
management_subnet = {
  name = "management"
  address_prefix = "x.x.x.x/x"
}

# Horizon Cloud dmz subnet, /27 minimum
dmz_subnet = {
  name = "dmz"
  address_prefix = "x.x.x.x/x"
}

# Horizon Cloud desktop subnet, /27 minimum, but sized appropriately based on the number of desktops and RDS servers.
desktop_subnet = {
  name = "desktop"
  address_prefix = "x.x.x.x/x"
}

# Custom DNS servers configured on the vnet, should be your internal DNS servers. Remember to add 168.63.129.16 as a DNS forwarder in your DNS servers.
dns_servers = [
  "x.x.x.x",
  "y.y.y.y"
]

# Connectivity type for the Horizon Edge management subnet. Selection of either "User Defined Route" or "NAT Gateway" configuration
# The value should be either "Route" or "NAT".
connectivity_type = "NAT"

# Public IP for NAT Gateway, ignore if you selected Route in the connectivity type
azure_public_ip = {
  ip_name = "PublicIP-HCoA-1"
  ip_allocation = "Static"
  ip_sku = "Standard"
}

# NAT Gateway, ignore if you selected Route in the connectivity type
nat_gateway = {
  name = "NatGW-HCoA"
  sku_name = "Standard"
}

# User Defined Route used by the AKS cluster and management subnet, ignore if you selected NAT Gateway in the connectivity type
route_table = {
  name              = "RouteTable-HCoA-MGMT"
  route_name        = "default_route"
  address_prefix    = "0.0.0.0/0"
  next_hop_type     = "VirtualNetworkGateway"
}

# Details for the Service principal and Managed Identity accounts
identities = {
  # Service Principal account
  service_principal_name = "HCoA-ServicePrincipal"
  # Service Principal secret
  service_principal_secret_name = "HCoA SP secret 2024"
  service_principal_secret_expiry = "17520h"
  # Managed Identity account
  managed_identity_name = "ManagedIdentity-HCoA"
}

# Service Principal application owners, use UPN format
service_principal_owners = [
  "user1@domain.com",
  "user2@domain.com"
]