#Requires -Version 5.0
#Requires -Modules Az.Resources

<#
    .SYNOPSIS
        Generates a report with resources
    
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
        https://github.com/scriptrunner/ActionPacks/blob/master/Azure/_REPORTS_
#>

param( 
)

Import-Module Az

try{
    [string[]]$Properties = @('Name','ResourceGroupName','ResourceType','Location')
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'ExpandProperties' = $ExpandProperties
    }

    $ret = Get-AzResource @cmdArgs | Sort-Object Name | Select-Object $Properties

    if($SRXEnv) {
        ConvertTo-ResultHtml -Result $ret
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