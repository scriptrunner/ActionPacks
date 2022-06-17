#Requires -Version 5.0
#requires -Modules Microsoft.Graph.Groups 

<#
    .SYNOPSIS
        Update entity in group Lifecycle Policy
    
    .DESCRIPTION          

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires Library script MS Graph\_LIB_\MGLibrary
        Requires Modules Microsoft.Graph.Groups 

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/MS%20Graph/Groups

    .PARAMETER AlternateNotificationEmails
        [sr-en] List of email address to send notifications for groups without owners. 
        Multiple email address can be defined by separating email address with a semicolon
        [sr-de] Liste der E-Mail-Adressen, an die Benachrichtigungen für Gruppen ohne Besitzer gesendet werden sollen. 
        Mehrere E-Mail-Adressen können definiert werden, indem die E-Mail-Adressen durch ein Semikolon getrennt werden
        
    .Parameter GroupLifetimeInDays
        [sr-en] Group identifier
        [sr-de] Gruppen ID
        
    .Parameter ManagedGroupType
        [sr-en] Group type for which the expiration policy applies
        [sr-de] Gruppentyp, für den die Ablauf-Richtlinie gilt
#>

param( 
    [string]$AlternateNotificationEmails,
    [int]$GroupLifetimeInDays,
    [ValidateSet('All','Selected','None')]
    [string]$ManagedGroupType
)

Import-Module Microsoft.Graph.Groups 

try{
    ConnectMSGraph 
    [hashtable]$cmdArgs = @{ErrorAction = 'Stop'}
    $mgPol = Get-MgGroupLifecyclePolicy @cmdArgs

    $cmdArgs.Add('Confirm',$false)
    $cmdArgs.Add('PassThru',$null)
    $cmdArgs.Add('GroupLifecyclePolicyId',$mgPol.Id)
    if($PSBoundParameters.ContainsKey('AlternateNotificationEmails') -eq $true){
        $cmdArgs.Add('AlternateNotificationEmails',$AlternateNotificationEmails)
    } 
    if($PSBoundParameters.ContainsKey('ManagedGroupType') -eq $true){
        $cmdArgs.Add('ManagedGroupTypes',$ManagedGroupType)
    } 
    if($PSBoundParameters.ContainsKey('GroupLifetimeInDays') -eq $true){
        $cmdArgs.Add('GroupLifetimeInDays',$GroupLifetimeInDays)
    } 

    $null = Update-MgGroupLifecyclePolicy @cmdArgs
    $mgPol = Get-MgGroupLifecyclePolicy -ErrorAction Stop | Select-Object *
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $mgPol
    }
    else{
        Write-Output $mgPol
    }
}
catch{
    throw 
}
finally{
    DisconnectMSGraph
}