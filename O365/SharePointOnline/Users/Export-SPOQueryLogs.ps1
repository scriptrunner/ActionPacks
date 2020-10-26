#Requires -Version 5.0
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
    .SYNOPSIS
        Export query logs for a user in an Office 365 tenant
    
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
        https://github.com/scriptrunner/ActionPacks/tree/master/O365/SharePointOnline/Users

    .Parameter LoginName
        Specifies the login name of the user to export

    .Parameter OutputFolder
        Target folder where the CSV file is generated

    .Parameter StartTime
        Specifies from which point of time to export the logs from
#>

param(            
    [Parameter(Mandatory = $true)]
    [string]$LoginName,
    [Parameter(Mandatory = $true)]
    [string]$OutputFolder,
    [Parameter(HelpMessage="ASRDisplay(Date)")]
    [datetime]$StartTime
)

Import-Module Microsoft.Online.SharePoint.PowerShell

try{
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'LoginName' = $LoginName
                            'OutputFolder' = $OutputFolder
                            }      
    if(($null -ne $StartTime) -and ($StartTime.Year -gt 2018)){
        $cmdArgs.Add('StartTime', $StartTime)
    }
    $null = Export-SPOQueryLogs @cmdArgs 
    $result = "Logs for $($LoginName) in folder $($OutputFolder) exported"
      
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