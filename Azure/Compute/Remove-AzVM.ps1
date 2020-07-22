#Requires -Version 5.0
#Requires -Modules Az.Compute

<#
    .SYNOPSIS
        Removes a virtual machine from Azure
    
    .DESCRIPTION  
        
    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires Module Az
        Requires Library script AzureAzLibrary.ps1

    .LINK
        https://github.com/scriptrunner/ActionPacks/blob/master/Azure        

    .Parameter AzureCredential
        The PSCredential object provides the user ID and password for organizational ID credentials, or the application ID and secret for service principal credentials

    .Parameter Tenant
        Tenant name or ID

    .Parameter Name
        Specifies the name of the virtual machine to remove

    .Parameter Name
        Remove also the associated resources

    .Parameter ResourceGroupName
        Specifies the name of a resource group

    .Parameter RemoveAssociatedResources
        Remove all associated resources
#>

param( 
    [Parameter(Mandatory = $true)]
    [pscredential]$AzureCredential,
    [Parameter(Mandatory = $true)]
    [string]$Name,
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,
    [switch]$RemoveAssociatedResources,
    [string]$Tenant
)

Import-Module Az.Compute

try{
#    ConnectAzure -AzureCredential $AzureCredential -Tenant $Tenant
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

    if($SRXEnv) {
        $SRXEnv.ResultMessage = $ret 
    }
    else{
        Write-Output $ret
    }
}
catch{
    throw
}
finally{
 #   DisconnectAzure -Tenant $Tenant
}