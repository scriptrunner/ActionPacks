#Requires -Version 5.0
#Requires -Modules Az.Compute

<#
    .SYNOPSIS
        Updates the state of an Azure virtual machine
    
    .DESCRIPTION  
        
    .NOTES
        This PowerShell script was originally developed for ScriptRunner and has been adapted for a non-ScriptRunner environment.

    .COMPONENT
        Requires Module Az.Compute

    .Parameter Name
        [sr-en] Specifies the name of the virtual machine
        [sr-de] Name der virtuellen Maschine

    .Parameter ResourceGroupName        
        [sr-en] Specifies the name of the resource group of the virtual machine
        [sr-de] Name der resource group die die virtuelle Maschine enthält
#>

param( [Parameter(Mandatory = $true)]
    [string]$Name,
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName
)

Import-Module Az.Compute

try{  
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Name' = $Name 
                            'ResourceGroupName' = $ResourceGroupName
                            }
    
    $vm = Get-AzVM @cmdArgs | Select-Object *
    
    $cmdArgs = @{'ErrorAction' = 'Stop'
                'Confirm' = $false 
                'VM' = $vm
                'ResourceGroupName' = $ResourceGroupName
                }
    
    $ret = Update-AzVM @cmdArgs

    Write-Output $ret
}
catch{
    throw
}
finally{
}