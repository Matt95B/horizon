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

# Custom DNS servers configured on the vnet, should be your internal DNS servers. 168.63.129.16 must remain as it is used for Azure internal routing
dns_servers = [
  "x.x.x.x",
  "y.y.y.y",
  "168.63.129.16"
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

# Custom roles and details for the Service principal and Managed Identity accounts
identities = {
  # Name and description of the custom role to be created in place of Contributor for Horizon Cloud Service Principals
  service_principal_role_name = "Custom - HCoA ServicePrincipal Role"
  service_principal_role_description = "Custom permissions required for deployment and operation of a Horizon Edge in Azure."
  # Name and description of the custom role to be created for Azure Compute Galleries
  compute_ro_role_name = "Custom - HCoA Compute Gallery Role"
  compute_ro_role_description = "Custom permissions required for Horizon Edge Azure Compute Galleries."
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

# Service Principal permissions for the custom role
# https://docs.omnissa.com/bundle/HorizonCloudServicesUsingNextGenGuide/page/ToUseaCustomRoleforHorizonCloudAppRegistration.html
service_principal_roles = [
  "Microsoft.Authorization/*/read",
  "Microsoft.Compute/*/read",
  "Microsoft.Compute/availabilitySets/*",
  "Microsoft.Compute/disks/*",
  "Microsoft.Compute/galleries/read",
  "Microsoft.Compute/galleries/write",
  "Microsoft.Compute/galleries/delete",
  "Microsoft.Compute/galleries/images/*",
  "Microsoft.Compute/galleries/images/versions/*",
  "Microsoft.Compute/images/*",
  "Microsoft.Compute/locations/*",
  "Microsoft.Compute/snapshots/*",
  "Microsoft.ContainerService/managedClusters/delete",
  "Microsoft.ContainerService/managedClusters/read",
  "Microsoft.ContainerService/managedClusters/write",        
  "Microsoft.ContainerService/managedClusters/commandResults/read",
  "Microsoft.ContainerService/managedClusters/runcommand/action",
  "Microsoft.ContainerService/managedClusters/upgradeProfiles/read",
  "Microsoft.ManagedIdentity/userAssignedIdentities/*/assign/action",
  "Microsoft.ManagedIdentity/userAssignedIdentities/*/read",
  "Microsoft.Compute/virtualMachines/*",
  "Microsoft.Compute/virtualMachineScaleSets/*",
  "Microsoft.MarketplaceOrdering/offertypes/publishers/offers/plans/agreements/read",
  "Microsoft.MarketplaceOrdering/offertypes/publishers/offers/plans/agreements/write",
  "Microsoft.Network/loadBalancers/*",           
  "Microsoft.Network/networkInterfaces/*",
  "Microsoft.Network/networkSecurityGroups/*",
  "Microsoft.Network/virtualNetworks/read",
  "Microsoft.Network/virtualNetworks/write",
  "Microsoft.Network/virtualNetworks/checkIpAddressAvailability/read",
  "Microsoft.Network/virtualNetworks/subnets/*",
  "Microsoft.Network/virtualNetworks/virtualNetworkPeerings/read",
  "Microsoft.ResourceGraph/*",
  "Microsoft.Resources/deployments/*",
  "Microsoft.Resources/subscriptions/read",
  "Microsoft.Resources/subscriptions/resourceGroups/*",
  "Microsoft.ResourceHealth/availabilityStatuses/read",
  "Microsoft.Storage/*/read",
  "Microsoft.Storage/storageAccounts/*",
  "Microsoft.KeyVault/*/read",
  "Microsoft.KeyVault/vaults/*",
  "Microsoft.KeyVault/vaults/secrets/*",
  "Microsoft.Network/natGateways/join/action",
  "Microsoft.Network/natGateways/read",
  "Microsoft.Network/privateEndpoints/write",
  "Microsoft.Network/privateEndpoints/read",
  "Microsoft.Network/publicIPAddresses/*",
  "Microsoft.Network/routeTables/join/action",
  "Microsoft.Network/routeTables/read"
]

# Service Principal permissions for the Compute Galleries custom role
compute_read_only_roles = ["Microsoft.Compute/galleries/read"]