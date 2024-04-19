#Requires -Version 5.0
#requires -Modules Microsoft.Graph.Users

<#
    .SYNOPSIS
        Updates settings for the primary mailbox of the user
    
    .DESCRIPTION          

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires Modules Microsoft.Graph.Users

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/MS%20Graph/Users

    .Parameter UserId
        [sr-en] User identifier
        [sr-de] Benutzer ID

    .Parameter DateFormat
        [sr-en] Date format for the user's mailbox
        [sr-de] Datums Format der Mailbox

    .Parameter TimeFormat
        [sr-en] Time format for the user's mailbox
        [sr-de] Zeit Format der Mailbox

    .Parameter TimeZone
        [sr-en] Default time zone for the user's mailbox
        [sr-de] Zeitzone der Mailbox
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$UserId,
    [string]$DateFormat,
    [string]$TimeFormat,
    [string]$TimeZone
)

Import-Module Microsoft.Graph.Users

try{
    [string[]]$Properties = @('DateFormat','TimeFormat','TimeZone','DelegateMeetingMessageDeliveryOptions','UserPurpose')
    [hashtable]$cmdArgs = @{ErrorAction = 'Stop'
                'UserId' = $UserId
                'Confirm' = $false
    }
    if($PSBoundParameters.ContainsKey('DateFormat') -eq $true){
        $cmdArgs.Add('DateFormat',$DateFormat)
    }
    if($PSBoundParameters.ContainsKey('TimeFormat') -eq $true){
        $cmdArgs.Add('TimeFormat',$TimeFormat)
    }
    if($PSBoundParameters.ContainsKey('TimeZone') -eq $true){
        $cmdArgs.Add('TimeZone',$TimeZone)
    }
    $null = Update-MgUserMailboxSetting @cmdArgs
    $result = Get-MgUserMailboxSetting -UserId $UserId | Select-Object $Properties
    
    if($null -ne $SRXEnv) {
        $SRXEnv.ResultMessage = $result
    }
    else{
        Write-Output $result
    }    
}
catch{
    throw 
}
finally{
}