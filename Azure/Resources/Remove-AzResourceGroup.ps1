#Requires -Version 5.0
#Requires -Modules Az.Resources

<#
    .SYNOPSIS
        Removes a resource group
    
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
        Specifies the name of the resource group to remove. Wildcard characters are not permitted

    .Parameter Identifier
        Specifies the ID of the resource group to remove. Wildcard characters are not permitted
#>

param( 
    [Parameter(Mandatory = $true, ParameterSetName="byName")]
    [Parameter(Mandatory = $true, ParameterSetName="byID")]
    [pscredential]$AzureCredential,
    [Parameter(Mandatory = $true,ParameterSetName="byName")]
    [string]$Name,
    [Parameter(Mandatory = $true,ParameterSetName="byID")]
    [string]$Identifier,
    [Parameter(ParameterSetName="byName")]
    [Parameter(ParameterSetName="byID")]
    [string]$Tenant
)

Import-Module Az

try{
#    ConnectAzure -AzureCredential $AzureCredential -Tenant $Tenant

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Confirm' = $false
                            'Force' = $null}
    
    if($PSCmdlet.ParameterSetName -eq "byID"){
        $cmdArgs.Add('ID',$Identifier)
        $Script:key = $Identifier
    }
    else{
        $cmdArgs.Add('Name',$Name)
        $Script:key = $Name
    }

    $null = Remove-AzResourceGroup @cmdArgs
    $ret = "Resource group $($Script:key) removed"

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
#    DisconnectAzure -Tenant $Tenant
}