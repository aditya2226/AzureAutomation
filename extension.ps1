param(

    [string]$tenantId="your tenant guid here"

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
           
           Get-AzureVMExtension -VM $VM | select ExtensionName, Publisher, Version
            
        }  
    }
    catch
    {
        Write-Host $error[0]
    }
}



