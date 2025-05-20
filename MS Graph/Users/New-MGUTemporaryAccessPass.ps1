#Requires -Version 5.0
#requires -Modules Microsoft.Graph.Identity.SignIns

<#
    .SYNOPSIS
        Create a new temporaryAccessPassAuthenticationMethod object on a user
    
    .DESCRIPTION          

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires Modules Microsoft.Graph.Identity.SignIns

    .Parameter UserId
        [sr-en] User identifier
        [sr-de] Benutzer ID

    .Parameter LifetimeInMinutes
        [sr-en] Lifetime of the Temporary Access Pass starting at StartDateTime, in minutes
        [sr-de] Laufzeit des Passes ab dem Startzeitpunkt, in Minuten

    .Parameter IsUsableOnce
        [sr-en] Pass is limited to a one-time use
        [sr-de] Pass kann nur einmal genutzt werden

    .Parameter UsabilityReason
        [sr-en] Details about the usability state
        [sr-de] Grund für den Pass

    .Parameter StartDateTime
        [sr-en] Date and time when the Temporary Access Pass becomes available to use
        [sr-de] Zeitpunkt ab wann der Pass gültig ist
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$UserId,
    [datetime]$StartDateTime,
    [ValidateRange(60,480)]
    [int]$LifetimeInMinutes = 60,
    [ValidateSet('EnabledByPolicy','DisabledByPolicy','Expired','NotYetValid','OneTimeUsed')]
    [string]$UsabilityReason = 'NotYetValid',
    [bool]$IsUsableOnce
)

Import-Module Microsoft.Graph.Identity.SignIns

try{
    if(($null -eq $StartDateTime) -or ($StartDateTime -lt [System.Datetime]::Now)){
        $StartDateTime = [System.Datetime]::Now
    }
    [hashtable]$cmdArgs = @{ErrorAction = 'Stop'
                'UserId' = $UserId
                'StartDateTime' = $StartDateTime
                'IsUsableOnce' = $IsUsableOnce
                'LifetimeInMinutes' = $LifetimeInMinutes
                'MethodUsabilityReason' = $UsabilityReason
    }
    $null = New-MgUserAuthenticationTemporaryAccessPassMethod @cmdArgs -Confirm:$false
    
    $result = Get-MgUserAuthenticationTemporaryAccessPassMethod $UserId -All -ErrorAction Stop
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