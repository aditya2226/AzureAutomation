param(

    [string]$tenantId="your tenant guid here",

    [string]$file="C:\temp\Azure-ARM-VMs.csv"
    ) 


if (Get-Module -ListAvailable -Name AzureRM) {
    Write-Host "Module exists"
} else {
    Install-Module AzureRM
}

Import-Module AzureRM

if ($tenantId -eq "") {
    login-azurermaccount 
    $subs = Get-AzureRmSubscription 
} else {
    login-azurermaccount -tenantid $tenantId 
    $subs = Get-AzureRmSubscription -TenantId $tenantId 
}


$vmobjs = @()

foreach ($sub in $subs)
{
    
    Write-Host Processing subscription $sub.SubscriptionName

    try
    {

        Select-AzureRmSubscription -SubscriptionId $sub.SubscriptionId -ErrorAction Continue

        $vms = Get-AzureRmVM 
       

        foreach ($vm in $vms)
        {
            $vmInfo = [pscustomobject]@{
                'Subscription'=$sub.Name
                'Location' = $vm.Location
                'ResourceGroupName' = $vm.ResourceGroupName
                'Name'=$vm.Name
                'ComputerName' = $vm.OSProfile.ComputerName
                'VMSize' = $vm.HardwareProfile.VMsize
                'DiskCount' = $vm.StorageProfile.DataDisks.Count
                'Admin' = $vm.OSProfile.AdminUsername
                'Status' = $null
                'IPAddress' = $null
                'OSDiskEncryption' = $null
                'DataDiskEncryption' = $null
                'VMagent' = $vm.ProvisionVMAgent
                'ProvisioningState' = $vm.ProvisioningState
                'Publisher' = $vm.StorageProfile.ImageReference.Publisher
                'Offer' = $vm.StorageProfile.ImageReference.Offer
                'SKU' = $vm.StorageProfile.ImageReference.Sku
                'Version' = $vm.StorageProfile.ImageReference.Version  
                
                 }
        
            $vmStatus = $vm | Get-AzureRmVM -Status
            $vmInfo.Status = $vmStatus.Statuses[1].DisplayStatus

            $nic = Get-AzureRmPublicIpAddress -ResourceGroupName $vm.ResourceGroupName
            $vmInfo.IPAddress =  $nic.IpAddress

            $vmosencryption = $vm | Get-AzureRmVMDiskEncryptionStatus -ResourceGroupName $vm.ResourceGroupName -VMName $vm.VMName
            $vmInfo.OSDiskEncryption = $vmosencryption.OsVolumeEncrypted

            $vmdataencryption = $vm | Get-AzureRmVMDiskEncryptionStatus
            $vmInfo.DataDiskEncryption = $vmdataencryption.DataVolumesEncrypted
            
            $vmobjs += $vmInfo
            Write-Host $vmInfo.Subscription $vmInfo.Name
        }  
    }
    catch
    {
        Write-Host $error[0]
    }
}

$vmobjs | Export-Csv -NoTypeInformation -Path $file
Write-Host "VM list written to $file"
Invoke-Item C:\temp\Azure-ARM-VMs.csv


