#Login-AzureRmAccount
#Get-AzureRmVMImageSku -Location westus -PublisherName new-signature  -Offer cloud-management-portal | Select PublisherName, Offer, Skus

#Login-AzureRmAccount  
$ResourceGroupName = "newSignature2"
$machinename="newsignature2"
$Location = "North Central US"

## Network
$InterfaceName = "newsignaturenetwork"
$Subnet1Name = "Subnet1"
$VNetName = "newsingatureVNet09"
$VNetAddressPrefix = "10.0.0.0/16"
$VNetSubnetAddressPrefix = "10.0.0.0/24"

## Compute
$VMName = "newsignaturenode1"
$ComputerName = "newsignaturemode1"+"comp"
$VMSize = "Standard_D14"
$OSDiskName = $machinename +"osdisk"

## Ubuntu
$imagePublisher = "new-signature"
$imageOffer = "cloud-management-portal"
$OSSku = "igvmv1"

             
            New-AzureRmResourceGroup -Name $ResourceGroupName -Location $Location


            $StorageAccount = New-AzureRmStorageAccount  -ResourceGroupName $ResourceGroupName  -Name $OSDiskName -Type "Standard_LRS" -Location $location
            
            ## Setup local VM object
            $VirtualMachine = New-AzureRmVMConfig -VMName $VMName -VMSize $VMSize
            $VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -Linux -ComputerName $ComputerName
            $VirtualMachine = Set-AzureRmVMSourceImage -VM $virtualMachine -PublisherName $imagePublisher -Offer $imageOffer -Skus $OSSku  -Version “latest”

            $VirtualMachine = Add-AzureRmVMNetworkInterface -VM $VirtualMachine -Id $Interface.Id
            $OSDiskUri = $StorageAccount.PrimaryEndpoints.Blob.ToString() + "vhds/" + $OSDiskName + ".vhd"
            $VirtualMachine = Set-AzureRmVMOSDisk -VM $VirtualMachine -Name $OSDiskName -VhdUri $OSDiskUri -CreateOption FromImage

            # NIC
            $InterfaceName = $VMName + "vip" 
            $PIp = New-AzureRmPublicIpAddress -Name $InterfaceName -ResourceGroupName $ResourceGroupName -Location $Location -AllocationMethod Dynamic
            $SubnetConfig = New-AzureRmVirtualNetworkSubnetConfig -Name $Subnet1Name -AddressPrefix $VNetSubnetAddressPrefix
            $VNet = New-AzureRmVirtualNetwork -Name $VNetName -ResourceGroupName $ResourceGroupName -Location $Location -AddressPrefix $VNetAddressPrefix -Subnet $SubnetConfig
            $Interface = New-AzureRmNetworkInterface -Name $InterfaceName -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[0].Id -PublicIpAddressId $PIp.Id
