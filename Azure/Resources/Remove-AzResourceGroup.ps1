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
        https://github.com/scriptrunner/ActionPacks/blob/master/Azure/Resources 

    .Parameter Name
        [sr-en] Specifies the name of the resource group to remove. Wildcard characters are not permitted
        [sr-de] Name der Resource Group

    .Parameter Identifier
        [sr-en] Specifies the ID of the resource group to remove. Wildcard characters are not permitted
        [sr-de] ID der Resource Group

#>

param( 
    [Parameter(Mandatory = $true,ParameterSetName="byName")]
    [string]$Name,
    [Parameter(Mandatory = $true,ParameterSetName="byID")]
    [string]$Identifier
)

Import-Module Az

try{
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
}