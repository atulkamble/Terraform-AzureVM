# Run

```bash
git clone https://github.com/atulkamble/Terraform-AzureVM.git
cd Terraform-AzureVM
chmod +x script.sh
./script.sh
```

# Azure Linux VM Architecture

This diagram represents the resources and Terraform relationships defined in this repository.

```mermaid
flowchart TB
  TF["Terraform configuration<br/>AzureRM provider 5.13.0"]
  SUB["Azure subscription"]
  RG["Resource group<br/>myResourceGroup<br/>Canada Central"]
  VNET["Virtual network: myVnet<br/>10.0.0.0/16"]
  SUBNET["Subnet: mySubnet<br/>10.0.1.0/24"]
  NIC["Network interface: myNIC<br/>Dynamic private IP"]
  PIP["Public IP: myPublicIP<br/>Standard SKU • Static allocation"]
  NSG["Network security group: myNSG<br/>Inbound TCP 22 allowed<br/>Source: * • Priority: 1001"]
  VM["Linux virtual machine: myVM<br/>Standard_D2s_v5<br/>Ubuntu Server 18.04 LTS<br/>OS disk: Standard_LRS • ReadWrite cache<br/>Admin username: adminuser"]
  KEY["SSH public key<br/>~/.ssh/id_rsa.pub"]
  CLIENT["Internet / SSH client"]

  TF --> SUB --> RG
  RG --> VNET
  VNET --> SUBNET --> NIC
  PIP --> NIC
  NIC --> VM
  RG --> NSG
  NSG -. "Associated with network interface" .-> NIC
  CLIENT --> PIP
  CLIENT -. "SSH • TCP 22" .-> NSG
  KEY --> VM
```

## Resource relationships

- The resource group contains the virtual network, public IP, network security group, network interface, and virtual machine.
- The subnet belongs to the virtual network. The network interface connects to that subnet and receives a dynamically allocated private IP.
- The static Standard public IP is attached to the network interface.
- The network security group is associated with the network interface and permits inbound SSH on TCP port 22 from any IPv4 source (`*`).
- The VM uses the SSH public key at `~/.ssh/id_rsa.pub` and a Standard_LRS OS disk.

## Security considerations

- The SSH rule allows connections from any source. Restrict `source_address_prefix` to a trusted public IP or CIDR range.
- The sample configuration contains an administrator password in plaintext. Do not commit real credentials; rotate any real password that has been exposed and use a secret store or another secure input method.
- The diagram intentionally omits the subscription ID and password.
- Ubuntu Server 18.04 LTS is an older image choice. Confirm support and image availability for the target subscription and region before deployment.
