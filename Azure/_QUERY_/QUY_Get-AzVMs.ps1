#Requires -Version 5.0
#Requires -Modules Az.Compute

<#
    .SYNOPSIS
        Gets the Azure virtual machines
    
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

    .LINK
        https://github.com/scriptrunner/ActionPacks/blob/master/Azure        

    .Parameter AzureCredential
        The PSCredential object provides the user ID and password for organizational ID credentials, or the application ID and secret for service principal credentials

    .Parameter Tenant
        Tenant name or ID
#>

param( 
    [Parameter(Mandatory = $true)]
    [pscredential]$AzureCredential,
    [string]$Tenant
)

Import-Module Az

$VerbosePreference = 'SilentlyContinue'

try{
 <#   if([System.String]::IsNullOrWhiteSpace($Tenant) -eq $true){
        $null = Connect-AzAccount -Credential $AzureCredential -Force -Confirm:$false -ErrorAction Stop
    }
    else{
        $null = Connect-AzAccount -Credential $AzureCredential -Tenant $Tenant -Force -Confirm:$false -ErrorAction Stop
    }
#>
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'}
    
    $vms = Get-AzVM @cmdArgs | Sort-Object Name

    foreach($vm in $vms){
        if($SRXEnv) {
            $null = $SRXEnv.ResultList.Add($vm.Name)
            $null = $SRXEnv.ResultList2.Add($vm.Name) # Display
        }
        else{
            Write-Output $grp.ResourceGroupName
        }
    }
 #   Disconnect-AzAccount -Confirm:$false -ErrorAction Stop
}
catch{
    throw
}
finally{
}