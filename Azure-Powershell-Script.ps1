# Step 1: Create the Resource Group
New-AzResourceGroup -Name "MST300-project1-rg" -Location "East US"

# ------------------------------------------------------------------------------------------------------------------------------------------------------- #

# Step 2: Get VM info
# Get-AzVMImagePublisher -Location "East US" | Where-Object { $_.PublisherName -like "*MicrosoftWindowsDesktop*" }

# Replace <PublisherName> with the actual name from the output above
# Get-AzVMImageOffer -Location "East US" -PublisherName "MicrosoftWindowsDesktop"

# Replace <Offer> with the actual offer name from the output above
# Get-AzVMImageSku -Location "East US" -PublisherName "MicrosoftWindowsDesktop" -Offer "Windows-10"

# Finally, find the specific version (if needed)
# Replace <Sku> with the actual SKU from the output above
# Get-AzVMImage -Location "East US" -PublisherName "MicrosoftWindowsDesktop" -Offer "Windows-10" -Skus "<Sku>"

# for this porject:
# -Skus "2019-Datacenter" -Offer "WindowsServer" -PublisherName "MicrosoftWindowsServer" -Version "latest"
# -Skus "win10-22h2-pro" -Offer "Windows-10" -PublisherName "MicrosoftWindowsDesktop" -Version "latest"

# ------------------------------------------------------------------------------------------------------------------------------------------------------- #

# Step 3: Create the Virtual Network and Subnet
## Create virtual network 1
$vnet1 = New-AzVirtualNetwork -ResourceGroupName "MST300-project1-rg" -Location "East US" -Name "MST300-vnet1" -AddressPrefix "10.1.0.0/16"
## Add subnet 1 configuration
$subnetConfig1 = Add-AzVirtualNetworkSubnetConfig -Name "vnet1-subnet1" -AddressPrefix "10.1.0.0/24" -VirtualNetwork $vnet1
## Add subnet 2 configuration
$subnetConfig2 = Add-AzVirtualNetworkSubnetConfig -Name "AzureBastionSubnet" -AddressPrefix "10.1.1.0/24" -VirtualNetwork $vnet1
## Set the subnet
$vnet1 = Set-AzVirtualNetwork -VirtualNetwork $vnet1


## Create virtual network 2
$vnet2 = New-AzVirtualNetwork -ResourceGroupName "MST300-project1-rg" -Location "East US" -Name "MST300-vnet2" -AddressPrefix "10.2.0.0/16"
## Add subnet 3 configuration
$subnetConfig3 = Add-AzVirtualNetworkSubnetConfig -Name "vnet2-subnet1" -AddressPrefix "10.2.0.0/24" -VirtualNetwork $vnet2
## Set the subnet
$vnet2 = Set-AzVirtualNetwork -VirtualNetwork $vnet2


## Create virtual network 3
$vnet3 = New-AzVirtualNetwork -ResourceGroupName "MST300-project1-rg" -Location "East US" -Name "MST300-vnet3" -AddressPrefix "10.3.0.0/16"
## Add subnet 4 configuration
$subnetConfig4 = Add-AzVirtualNetworkSubnetConfig -Name "vnet3-subnet1" -AddressPrefix "10.3.0.0/24" -VirtualNetwork $vnet3
## Set the subnet
$vnet3 = Set-AzVirtualNetwork -VirtualNetwork $vnet3


# Optional Public IP
# $dnsLabel1 = "my-dns1" # This needs to be unique within the Azure region (only lowercase)
# $dnsLabel2 = "my-dns2" # This needs to be unique within the Azure region (only lowercase)
# $dnsLabel3 = "my-dns3" # This needs to be unique within the Azure region (only lowercase)

# $publicIp1 = New-AzPublicIpAddress -Name "myPublicIp1" -ResourceGroupName "MST300-project1-rg" -Location "East US" -AllocationMethod Static -Sku Standard -DomainNameLabel $dnsLabel1
# $publicIp2 = New-AzPublicIpAddress -Name "myPublicIp2" -ResourceGroupName "MST300-project1-rg" -Location "East US" -AllocationMethod Static -Sku Standard -DomainNameLabel $dnsLabel2
# $publicIp3 = New-AzPublicIpAddress -Name "myPublicIp3" -ResourceGroupName "MST300-project1-rg" -Location "East US" -AllocationMethod Static -Sku Standard -DomainNameLabel $dnsLabel3

# ------------------------------------------------------------------------------------------------------------------------------------------------------- #

# Step 5: Create the Network Security Group (NSG)
$nsg1 = New-AzNetworkSecurityGroup -ResourceGroupName "MST300-project1-rg" -Location "East US" -Name "myNSGPS-vnet1"
$nsg2 = New-AzNetworkSecurityGroup -ResourceGroupName "MST300-project1-rg" -Location "East US" -Name "myNSGPS-vnet2"
$nsg3 = New-AzNetworkSecurityGroup -ResourceGroupName "MST300-project1-rg" -Location "East US" -Name "myNSGPS-vnet3"

# ------------------------------------------------------------------------------------------------------------------------------------------------------- #

# Step 6: Create the Network Interface (NIC)
$vnet1 = Get-AzVirtualNetwork -Name "MST300-vnet1" -ResourceGroupName "MST300-project1-rg"
$subnetConfig1 = $vnet1.Subnets | Where-Object { $_.Name -eq "vnet1-subnet1" }
$nic1 = New-AzNetworkInterface -Name "dc-vm-nic" -ResourceGroupName "MST300-project1-rg" -Location "East US" -SubnetId $subnetConfig1.Id -NetworkSecurityGroupId $nsg1.Id # -PublicIpAddressId $publicIp1.Id # optional

$vnet2 = Get-AzVirtualNetwork -Name "MST300-vnet2" -ResourceGroupName "MST300-project1-rg"
$subnetConfig3 = $vnet2.Subnets | Where-Object { $_.Name -eq "vnet2-subnet1" }
$nic2 = New-AzNetworkInterface -Name "webserver-vm-nic" -ResourceGroupName "MST300-project1-rg" -Location "East US" -SubnetId $subnetConfig3.Id -NetworkSecurityGroupId $nsg2.Id # -PublicIpAddressId $publicIp2.Id # optional

$vnet3 = Get-AzVirtualNetwork -Name "MST300-vnet3" -ResourceGroupName "MST300-project1-rg"
$subnetConfig4 = $vnet3.Subnets | Where-Object { $_.Name -eq "vnet3-subnet1" }
$nic3 = New-AzNetworkInterface -Name "client-vm-nic" -ResourceGroupName "MST300-project1-rg" -Location "East US" -SubnetId $subnetConfig4.Id -NetworkSecurityGroupId $nsg3.Id # -PublicIpAddressId $publicIp3.Id # optional

# ------------------------------------------------------------------------------------------------------------------------------------------------------- #

# Step 7 Create VMs
## VM 1 Configuration

# Define your credentials (Optional)
# $username1 = "..."
# $password1 = "..." | ConvertTo-SecureString -AsPlainText -Force

# Create the credential object
# $credential1 = New-Object System.Management.Automation.PSCredential($username1, $password1)

$vmConfig1 = New-AzVMConfig -VMName "dc-vm" -VMSize "Standard_D2s_v3" |
Set-AzVMOperatingSystem -Windows -ComputerName "dc-vm" -Credential (Get-Credential) -ProvisionVMAgent -EnableAutoUpdate |
Set-AzVMSourceImage -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer" -Skus "2019-Datacenter" -Version "latest" |
Add-AzVMNetworkInterface -Id $nic1.Id |
Set-AzVMOSDisk -CreateOption FromImage -StorageAccountType "StandardSSD_LRS"
## Disable Boot Diagnostics using the updated cmdlet
$vmConfig1 = $vmConfig1 | Set-AzVMBootDiagnostic -Disable
## Create the VM
New-AzVM -ResourceGroupName "MST300-project1-rg" -Location "East US" -VM $vmConfig1



## VM 2 Configuration

# Define your credentials (Optional)
# $username2 = "..."
# $password2 = "..." | ConvertTo-SecureString -AsPlainText -Force

# Create the credential object
# $credential2 = New-Object System.Management.Automation.PSCredential($username2, $password2)

$vmConfig2 = New-AzVMConfig -VMName "webserver-vm" -VMSize "Standard_D2s_v3" |
Set-AzVMOperatingSystem -Windows -ComputerName "webserver-vm" -Credential (Get-Credential) -ProvisionVMAgent -EnableAutoUpdate |
Set-AzVMSourceImage -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer" -Skus "2019-Datacenter" -Version "latest" |
Add-AzVMNetworkInterface -Id $nic2.Id |
Set-AzVMOSDisk -CreateOption FromImage -StorageAccountType "StandardSSD_LRS"
## Disable Boot Diagnostics using the updated cmdlet
$vmConfig2 = $vmConfig2 | Set-AzVMBootDiagnostic -Disable
## Create the VM
New-AzVM -ResourceGroupName "MST300-project1-rg" -Location "East US" -VM $vmConfig2



## VM 3 Configuration

# Define your credentials (Optional)
# $username3 = "..."
# $password3 = "..." | ConvertTo-SecureString -AsPlainText -Force

# Create the credential object
# $credential3 = New-Object System.Management.Automation.PSCredential($username3, $password3)

$vmConfig3 = New-AzVMConfig -VMName "client-vm" -VMSize "Standard_DS1_v2" |
Set-AzVMOperatingSystem -Windows -ComputerName "client-vm" -Credential (Get-Credential) -ProvisionVMAgent -EnableAutoUpdate |
Set-AzVMSourceImage -PublisherName "MicrosoftWindowsDesktop" -Offer "Windows-10" -Skus "win10-22h2-pro" -Version "latest" |
Add-AzVMNetworkInterface -Id $nic3.Id |
Set-AzVMOSDisk -CreateOption FromImage -StorageAccountType "StandardSSD_LRS"
## Disable Boot Diagnostics using the updated cmdlet
$vmConfig3 = $vmConfig3 | Set-AzVMBootDiagnostic -Disable
## Create the VM
New-AzVM -ResourceGroupName "MST300-project1-rg" -Location "East US" -VM $vmConfig3


# ------------------------------------------------------------------------------------------------------------------------------------------------------- #


# Individual commands to stop each VM
#Stop-AzVM -Name "dc-vm" -ResourceGroupName "MST300-project1-rg" -Force
#Stop-AzVM -Name "webserver-vm" -ResourceGroupName "MST300-project1-rg" -Force
#Stop-AzVM -Name "client-vm" -ResourceGroupName "MST300-project1-rg" -Force


# ------------------------------------------------------------------------------------------------------------------------------------------------------- #


# Step 1: Create Peering Connections

# Peering VNet1 to VNet2
az network vnet peering create --name VNet1ToVNet2 --resource-group MST300-project1-rg --vnet-name MST300-vnet1 --remote-vnet MST300-vnet2 --allow-vnet-access --allow-forwarded-traffic --allow-gateway-transit
az network vnet peering create --name VNet2ToVNet1 --resource-group MST300-project1-rg --vnet-name MST300-vnet2 --remote-vnet MST300-vnet1 --allow-vnet-access --allow-forwarded-traffic --allow-gateway-transit

# Peering VNet1 to VNet3
az network vnet peering create --name VNet1ToVNet3 --resource-group MST300-project1-rg --vnet-name MST300-vnet1 --remote-vnet MST300-vnet3 --allow-vnet-access --allow-forwarded-traffic --allow-gateway-transit
az network vnet peering create --name VNet3ToVNet1 --resource-group MST300-project1-rg --vnet-name MST300-vnet3 --remote-vnet MST300-vnet1 --allow-vnet-access --allow-forwarded-traffic --allow-gateway-transit

# Peering VNet2 to VNet3
az network vnet peering create --name VNet2ToVNet3 --resource-group MST300-project1-rg --vnet-name MST300-vnet2 --remote-vnet MST300-vnet3 --allow-vnet-access --allow-forwarded-traffic --allow-gateway-transit
az network vnet peering create --name VNet3ToVNet2 --resource-group MST300-project1-rg --vnet-name MST300-vnet3 --remote-vnet MST300-vnet2 --allow-vnet-access --allow-forwarded-traffic --allow-gateway-transit


# -------------- # RDP and HTTP

# Run the following to allow RDP 3389 port on dc-vm
# az network nsg rule create --resource-group MST300-project1-rg --nsg-name myNSGPS-vnet1 --name AllowRDP --priority 1000 --source-address-prefixes '*' --source-port-ranges '*' --destination-address-prefixes '*' --destination-port-ranges 3389 --direction Inbound --access Allow --protocol Tcp --description "Allow RDP"

# Run the following to allow HTTP 80 and RDP 3389 port on webserver
# az network nsg rule create --resource-group MST300-project1-rg --nsg-name myNSGPS-vnet2 --name AllowRDP --priority 1000 --source-address-prefixes '*' --source-port-ranges '*' --destination-address-prefixes '*' --destination-port-ranges 3389 --direction Inbound --access Allow --protocol Tcp --description "Allow RDP"

az network nsg rule create --resource-group MST300-project1-rg --nsg-name myNSGPS-vnet2 --name AllowHTTP --priority 1010 --source-address-prefixes '*' --source-port-ranges '*' --destination-address-prefixes '*' --destination-port-ranges 80 --direction Inbound --access Allow --protocol Tcp --description "Allow HTTP"

# Run the following to allow RDP 3389 port on client-vm
# az network nsg rule create --resource-group MST300-project1-rg --nsg-name myNSGPS-vnet3 --name AllowRDP --priority 1000 --source-address-prefixes '*' --source-port-ranges '*' --destination-address-prefixes '*' --destination-port-ranges 3389 --direction Inbound --access Allow --protocol Tcp --description "Allow RDP"



# -------------- # Deploy Azure Bastion



# Intall extension
az config set extension.use_dynamic_install=yes_without_prompt


# create Public IP Address
az network public-ip create `
    --resource-group MST300-project1-rg `
    --name MST300-BastionIP `
    --sku Standard `
    --location eastus `
    --allocation-method Static


# Name: MST300-BastionHost
# Region: Use the same region as your vnets
# Instance count: 3
# Virtual network: MST300-vnet1
# Subnet: AzureBastionSubnet
# Create new Public IP address
# Public IP address name: MST300-BastionIP
az network bastion create `
    --name MST300-BastionHost `
    --resource-group MST300-project1-rg `
    --location eastus `
    --vnet-name MST300-vnet1 `
    --public-ip-address MST300-BastionIP `
    --sku Standard `
    --scale-unit 3



# -------------- # Active Directory Domain Services

# On the domain cotroller:
#   1. Fix IPv4 (ipconfig /all) [<<== This is the CMD you need to run on Powershell]
#     a. Server Manager -> Local Server -> Ethernet -> Ethernet(right click) -> Porperties -> IPv4 -> Properties
#     b. Use static ip
#       - IP address = VM ip
#       - Subnet mask = VM mask
#       - Default gateway = VM default gateway
#       - Preferred DNS server = VM ip
#       - Alternative DNS server = 8.8.8.8
#
#   2. Manage -> Add roles and features -> ... -> Server Rules
#     a. Install Active Directory Domain Services
#     b. Install DNS Server
#
#   3. Promote server to domain controller
#     a. Add a new forest -> root domain name: domainName.com
#     b. Password: PassWord123$
#     c. The NetBIOS domain name: domainName

# Your new login information:
#   - domainName\admin123 [Original VM login username]
#   OR
#   - admin123@domainName.com
#
#   1. Login into Domain Controller VM
#     a. User: domainName.admin
#     b. Member of Domain Administrators
#
#   2. Add new user to the domain controller
#     a. Server Manager -> Tools -> Active Directory Users and Computers
#     b. add the following user:
#       - User: domainName
#       - Member of Domain Users, Remote Desktop Access, remote controll permission
#     c. add the following user:
#       - User: domainName.admin
#       - Member of Domain Admin
#
#   3. Modify DNS Manager config
#     a. Server Manager -> Tools -> DNS Manager
#     b. Expand the server name
#     c. Right click on Reverse Lookup Zone
#       - New zone
#       - Click on Next until Network ID appears
#       - Network ID = VM ip
#       - next until finish
#     d. Expand the Forward Lookup Zones
#       - double click on the (vm name   ...   VM IP   ...   static)
#       - CHECKBOX mark checked "Update associated pointer (PTR) record"
#       - apply
#     e. Reverse Lookup Zones -> click on the one you just created
#       - right click on the white part -> refresh
#
#   4. Server Manager -> Local Server -> Ethernet -> Right click Ethernet -> properties -> IPv4 -> properties
#     a. Change Preffered DNS Server = VM ip
#

#   1. check connectivity (ping) (nslookup)
#     a. Powershell: nslookup
#     b. domainName.com
#     c. Domain Controller VM IP address
#


# Allow Connections

#az network nsg rule create --resource-group MST300-project1-rg --nsg-name myNSGPS-vnet1 --name AllowLDAP --priority 1030 --direction Inbound --access Allow --protocol Tcp --source-address-prefixes '*' --source-port-ranges '*' --destination-address-prefixes '*' --destination-port-ranges 389
#az network nsg rule create --resource-group MST300-project1-rg --nsg-name myNSGPS-vnet2 --name AllowLDAP --priority 1030 --direction Inbound --access Allow --protocol Tcp --source-address-prefixes '*' --source-port-ranges '*' --destination-address-prefixes '*' --destination-port-ranges 389
#az network nsg rule create --resource-group MST300-project1-rg --nsg-name myNSGPS-vnet3 --name AllowLDAP --priority 1030 --direction Inbound --access Allow --protocol Tcp --source-address-prefixes '*' --source-port-ranges '*' --destination-address-prefixes '*' --destination-port-ranges 389

#   1. Run the following on all VMs
#     a. On Powershell: New-NetFirewallRule –DisplayName “Allow ICMPv4-In” –Protocol ICMPv4
#


#   1. On the webserver-vm install Web Server (ISS)
#   2. IIS Manager -> change the page title
#


#   1. (Add machines to the Domain) On the machine that will join the Active Domain
#     a. On the IPv4 properties
#     b. Use static ip
#       - IP address = VM ip
#       - Subnet mask = VM mask
#       - Default gateway = VM default gateway
#       - Preferred DNS server = DOMAIN CONTROLLER VM ip
#
#   2. perform a connectivity test on the current vm
#     a. Powershell: ping DNS server ip
#     b. Powershell: nslookup domainName.com
#
#   3. System and Security -> System -> Change Settings
#     a. System Properties -> Change (Domain or workgroup)
#     b. Computer Name: [webserver-vm or client-vm]
#     c. Member of: Domain: domainName.com
#       - OK -> domainName\admin + PassWord123$
#
#


# https://www.youtube.com/watch?v=h3AFR2hPEDM
# https://www.youtube.com/watch?v=86TU6wZfPfk
# https://www.youtube.com/watch?v=h3sxduUt5a8


# access the webserver using: <computer's name>.<active directory domain's forest>
# access the DNS controller on the domain controller's VM.
# # In the DNS Manager, navigate to your DNS zone for mytest.local. This should be under Forward Lookup Zones.
# # Right-click on the zone (mytest.local) and select New Host (A or AAAA)... from the context menu.
# # Enter the Host name (e.g., webserver) and the IP address of the web server's VM. Ensure that "Create associated pointer (PTR) record" is checked if you want reverse lookup to work.
# # Click Add Host to create the record.

# Final Fix for the user without admin privileges to connect to the client vm

# 0. Logged in the VM as administrator
# 1. searched for "This PC"
# 2. right-click "This PC" -> Properties
# 3. opened "Remote Desktop"
# 4. User accounts ->  Select users that can remotely access this PC
# 5. Manually added the username from the user that I created on the domain
# OR
# 5. Manually added the Domain Users group on the domain

# Alternative solution
# 1. control panel
# 2. System and security
# 3. User account
# 4. Manage User accounts
# 5. Add the new user

# 1. Final Step on the Domain Controler -> Active Directory users and computers
# 2. rename admin to domainName.admin
