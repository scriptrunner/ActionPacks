#Requires -Version 5.0
#Requires -Modules Az.Compute

<#
    .SYNOPSIS
        Updates the state of an Azure virtual machine
    
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
        https://github.com/scriptrunner/ActionPacks/blob/master/Azure/Compute

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
}