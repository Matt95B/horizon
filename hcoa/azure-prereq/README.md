# Horizon Cloud on Azure next-gen pre-requisites deployment via Terraform.
Scripts to build the required Azure infrastructure components to support a deployment of Horizon Cloud on Azure (HCoA) next-gen. It uses Terraform to create the Azure resources needed for the deployment of the Horizon Edge (AKS).

Tested with azuread 3.0.2 and azurerm 4.0.1 providers on macOS 14.7.

## The Terraform workflow will
### In Azure:
- Create a single Resouce Group in your Azure subscription
- Create a VNet in this Resource Group
- Create three (3) Subnets in this VNet:
  - Management Subnet
  - DMZ Subnet
  - Desktop Subnet
- Create either a Route Table or NAT Gateway, based on the connectivity type selection in the variable file
  - Route Table
    - Create a default route in the Route Table
    - Assign the default route to the Management subnet
  - NAT Gateway
    - Create a Public IP for a NAT Gateway
    - Create a NAT Gateway
    - Assign the NAT Gateway to the Management Subnet
- Assign the DNS Server settings to the VNet
- Create two (2) Custom Roles:
  - Service Principal Role with minimum capabilities needed for the Service Principal used by Horizon Cloud
  - Azure Compute Read-Only role with permissions on to Read on Azure Compute Resources
- Create a User Managed Identity
- Assign to the Managed Identity the Network Contributor & Managed Identity Operator built-in roles.
- Create an Enterprise Application.
- Create a Service Principal, Client ID and Client Secret for the Enterprise Application.

# Before you begin
1. Ensure you have PowerShell installed for your OS, and the AZ module.
2. Ensure you have the Azure Command Line Tools installed for your OS.
3. Ensure you have Terraform installed for your OS.
4. Ensure your Entra ID account has the Azure Owner role assigned on your Azure susbcription

# Instructions:
1. Register the required Azure Service Providers via `PowerShell` for Horizon Cloud.
https://docs.omnissa.com/bundle/HorizonCloudServicesUsingNextGenGuide/page/ConfirmRequiredResourceProvidersAreRegisteredinYourMicrosoftAzureSubscription.html
```
Connect-AzAccount
$resource_providers_list = @("Microsoft.Authorization",
                           "Microsoft.Compute",
                           "Microsoft.ContainerService",
                           "Microsoft.KeyVault",
                           "Microsoft.MarketplaceOrdering",
                           "Microsoft.ResourceGraph",
                           "Microsoft.Network",
                           "Microsoft.Resources",
                           "Microsoft.Security",
                           "Microsoft.Storage",
                           "Microsoft.ManagedIdentity"
)
$resource_providers_list | ForEach-Object {
  Register-AzResourceProvider -ProviderNamespace $_
}
```

2. Edit the `terraform.tfvars` file and adjust the variables to suit your environment.

3. Open your command line tool of choice and navigate to the folder where your Terraform scripts are located
```
cd ~/Downloads/Terraform_HCoAdeploy
```

4. Log in to your Azure environment and select your Azure subscription where you want to deploy Horizon Cloud
```
az login
az account set --subscription "Your Azure Subscription Name"
```

5. On the very first run, you need to get the Terraform Providers.
```
terraform init
```

6. Test your config using
```
terraform validate
```

7. Now you will be able to deploy against your settings:
```
terraform plan -out HCoADeploy
terraform apply HCoADeploy
```

8. Copy and save the output details once the script finishes, you will need those details when deploying the Horizon Edge. In addition, run the below commands to reveal the sensitive values.
```
terraform output service_principal_pwd_id
terraform output service_principal_pwd_key
```

9. Implement the reminder of the pre-requisites for Horizon Cloud as per the documentation.
https://docs.omnissa.com/bundle/HorizonCloudServicesUsingNextGenGuide/page/RequirementsChecklistforDeployingaMicrosoftAzureEdge.html

# Changelog
2024-11-25 - Removed Azure Resource Providers registration from Terraform workflow. Resource Providers registration is now done via PowerShell instead to avoid (1)registration errors if already resgisterred and (2)retain registration during Terraform destroy.

2024-11-19 - Added the option to select connectivity type for the management subnet (NAT vs Route).

2024-11-06 - Initial release.
