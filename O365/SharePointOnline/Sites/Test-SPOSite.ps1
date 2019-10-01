#Requires -Version 5.0
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
    .SYNOPSIS
        Tests a SharePoint Online site collection
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires Module Microsoft.Online.SharePoint.PowerShell
        ScriptRunner Version 4.2.x or higher

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/O365/SharePointOnline/Sites

    .Parameter Identity
        Specifies the SharePoint Online site collection to test

    .Parameter RuleId
        Specifies the health check rule to run

    .Parameter RunAlways
        Displays a message that states the effect of the command instead of executing the command
#>

param(        
    [Parameter(Mandatory=$true)]
    [string]$Identity,
    [string]$RuleId,
    [switch]$RunAlways
)

Import-Module Microsoft.Online.SharePoint.PowerShell

try{
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Identity' = $Identity
                            'RunAlways' = $RunAlways
                            }      
    
    if([System.String]::IsNullOrWhiteSpace($RuleId) -eq $false){
        $cmdArgs.Add('RuleId',$RuleId)
    }
    
    $result = Test-SPOSite @cmdArgs | Select-Object *

    if($SRXEnv) {
        $SRXEnv.ResultMessage = $result
    }
    else {
        Write-Output $result 
    }    
}
catch{
    throw
}
finally{
}