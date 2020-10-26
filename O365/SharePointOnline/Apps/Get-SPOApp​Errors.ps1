#Requires -Version 5.0
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
    .SYNOPSIS
        Returns application errors
    
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
        https://github.com/scriptrunner/ActionPacks/tree/master/O365/SharePointOnline/Apps

    .Parameter ProductID
        Specifies the application’s GUID

    .Parameter EndTimeInUtc
        Specifies the end time in UTC to search for monitoring errors

    .Parameter StartTimeInUtc
        Specifies the start time in UTC to search for monitoring errors
#>

param(   
    [Parameter(Mandatory = $true)]  
    [string]$ProductID,
    [Parameter(HelpMessage="ASRDisplay(Date)")]
    [datetime]$EndTimeInUtc,
    [Parameter(HelpMessage="ASRDisplay(Date)")]
    [datetime]$StartTimeInUtc
)

Import-Module Microsoft.Online.SharePoint.PowerShell

try{    
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'ProductID' = $ProductID
                            }

    if(($null -ne $EndTimeInUtc) -and ($EndTimeInUtc.Year -gt 2015)){
        $cmdArgs.Add('EndTimeInUtc',$EndTimeInUtc)
    }
    if(($null -ne $StartTimeInUtc) -and ($StartTimeInUtc.Year -gt 2015)){
        $cmdArgs.Add('StartTimeInUtc',$StartTimeInUtc)
    }

    $result = Get-SPOAppErrors @cmdArgs | Select-Object *
      
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