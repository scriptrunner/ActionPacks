#Requires -Version 4.0
#Requires -Modules SkypeOnlineConnector

<#
    .SYNOPSIS
        Returns the identified Call Queues
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires Module SkypeOnlineConnector
        Requires Library script SFBLibrary.ps1
        ScriptRunner Version 4.2.x or higher

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/O365/Skype4Business/Settings

    .Parameter SFBCredential
        Credential object containing the Skype for Business user/password

    .Parameter Descending
        The Descending parameter sorts Call Queues in descending order

    .Parameter ExcludeContent
        The ExcludeContent parameter only displays the Name and Id of the Call Queues

    .Parameter First
        The First parameter gets the first N Call Queues

    .Parameter Skip
        The Skip parameter skips the first N Call Queues
#>

param(    
    [Parameter(Mandatory = $true)]
    [PSCredential]$SFBCredential,  
    [switch]$Descending,
    [switch]$ExcludeContent,
    [int]$First = 100,
    [int]$Skip
)

Import-Module SkypeOnlineConnector

try{
    ConnectS4B -S4BCredential $SFBCredential

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Descending' =$Descending
                            'ExcludeContent' = $ExcludeContent
                            'First' = $First
                            }      
    if($Skip -gt 0){
        $cmdArgs.Add('Skip',$Skip)
    }  

    $result = Get-CsCallQueue @cmdArgs | Select-Object *

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
    DisconnectS4B
}