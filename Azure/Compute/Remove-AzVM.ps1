#Requires -Version 5.0
#Requires -Modules Az.Compute

<#
    .SYNOPSIS
        Removes a virtual machine from Azure
    
    .DESCRIPTION  
        This script is inspired by the article "Delete an Azure VM with objects using PowerShell" by Adam Bertram published by 4sysops.
        
    .NOTES
        This PowerShell script was originally developed for ScriptRunner and has been adapted for a non-ScriptRunner environment.

    .COMPONENT
        Requires Module Az.Compute

    .LINK
        https://4sysops.com/archives/delete-an-azure-vm-with-objects-using-powershell/       
        https://github.com/adbertram/Random-PowerShell-Work/blob/master/Azure/Remove-AzrVirtualMachine.ps1

    .Parameter Name
        [sr-en] Specifies the name of the virtual machine
        [sr-de] Name der virtuellen Maschine

    .Parameter ResourceGroupName
        [sr-en] Specifies the name of the resource group of the virtual machine
        [sr-de] Name der resource group die die virtuelle Maschine enthält

    .Parameter RemoveAssociatedResources
        [sr-en] Remove all associated resources
        [sr-de] Löschen aller verwendeter Ressourcen der virtuellen Maschine 
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$Name,
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,
    [switch]$RemoveAssociatedResources
)

Import-Module Az.Compute

try{
    $Script:VM = Get-AzVM -ResourceGroupName $ResourceGroupName -Name $Name -ErrorAction Stop
    $Script:Disks = Get-AzDisk | Where-Object { $_.ManagedBy -eq $Script:VM.Id }
    function RemoveResourcesAfterDelete(){
        
        try{
            # remove vNICs
            Write-Output "remove vNICs"
            foreach($nicID in $Script:VM.NetworkProfile.NetworkInterfaces.Id) {
				$tmpNic = Get-AzNetworkInterface -ResourceGroupName $Script:VM.ResourceGroupName -Name $nicID.Split('/')[-1]
				$null = Remove-AzNetworkInterface -Name $tmpNic.Name -ResourceGroupName $Script:VM.ResourceGroupName -Force
				foreach($ipAddress in $tmpNic.IpConfigurations) {
					if($null -ne $ipAddress.PublicIpAddress) {
						$null = Remove-AzPublicIpAddress -ResourceGroupName $Script:VM.ResourceGroupName -Name $ipAddress.PublicIpAddress.Id.Split('/')[-1] -Force
					} 
				}
            } 
            # remove os disk
            if ('Uri' -in $Script:VM.StorageProfile.OSDisk.Vhd) {
                Write-Output "remove os blob"
				$diskId = $Script:VM.StorageProfile.OSDisk.Vhd.Uri
				$conName = $diskId.Split('/')[-2]

				$stoAcc = Get-AzStorageAccount | Where-Object { $_.StorageAccountName -eq $diskId.Split('/')[2].Split('.')[0] }
				$stoAcc | Remove-AzStorageBlob -Container $conName -Blob $diskId.Split('/')[-1]

				$stoAcc | Get-AzStorageBlob -Container $conName -Blob "$($Script:VM.Name)*.status" | Remove-AzStorageBlob
			} 
            else {
                if($null -ne $Script:Disks){
                    $Script:Disks | Remove-AzDisk -Force -Confirm:$false
                }		 		 
			}
            # Remove other disks
            Write-Output "remove other disks"
            if ('DataDiskNames' -in $Script:VM.PSObject.Properties.Name -and @($Script:VM.DataDiskNames).Count -gt 0) {
                foreach ($item in $Script:VM.StorageProfile.DataDisks.Vhd.Uri) {
                    $stoAcc = Get-AzStorageAccount -Name $item.Split('/')[2].Split('.')[0]
                    $stoAcc | Remove-AzStorageBlob -Container $item.Split('/')[-2] -Blob $item.Split('/')[-1]
                }
            }
            # remove network securtity group
            Write-Output "remove network securtity group"
            $secGroup = Get-AzNetworkSecurityGroup -Name "$($Script:VM.Name)*" -ResourceGroupName $ResourceGroupName
            if($null -ne  $secGroup){
                $null = Remove-AzNetworkSecurityGroup -Name $secGroup.Name -ResourceGroupName $ResourceGroupName -Confirm:$false -Force
            }
        }
        catch{
            Write-Output $_.Exception.Message
        }
    }
    function RemoveResourcesBeforeDelete(){
        
        try{
            if ($null -eq $Script:VM.DiagnosticsProfile.bootDiagnostics) {
                return
            }
            # remove bootDiagnostics
            Write-Output "remove boot diagnostics"
            [string]$stoName = [regex]::match($Script:VM.DiagnosticsProfile.bootDiagnostics.storageUri, '^http[s]?://(.+?)\.').groups[1].value
            [int]$nameLength = 9
            if($Script:VM.Name.Length -lt 9){
                $nameLength = ($Script:VM.Name.Length - 1)
            }
            [string]$conName = ('bootdiagnostics-{0}-{1}' -f $Script:VM.Name.ToLower().Substring(0, $nameLength), $Script:VM.vmId)
            [string]$resgrpName = (Get-AzStorageAccount | Where-Object { $_.StorageAccountName -eq $stoName }).ResourceGroupName
            [hashtable]$cmdArgs = @{
                'ResourceGroupName' = $resgrpName
                'Name' = $stoName
            }     
            Get-AzStorageAccount @cmdArgs | `
                        Get-AzStorageContainer | Where-Object { $_.Name -eq $conName }  | `
                        Remove-AzStorageContainer –Force -ErrorAction Stop
        }
        catch{
            Write-Output $_.Exception.Message
        }
    }

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Confirm' = $false
                            'Force' = $null
                            'Name' = $Name
                            'ResourceGroupName' = $ResourceGroupName}
    
    if($RemoveAssociatedResources.IsPresent){ # delete resources that must be removed before remove vm
        RemoveResourcesBeforeDelete
    }

    $null = Remove-AzVM @cmdArgs
    
    if($RemoveAssociatedResources.IsPresent){ # delete resources that must be removed after remove vm
        RemoveResourcesAfterDelete
    }

    $ret = "Virtual machine $($Name) removed"

    Write-Output $ret
}
catch{
    throw
}
finally{
}