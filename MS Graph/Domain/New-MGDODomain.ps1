#Requires -Version 5.0
#requires -Modules Microsoft.Graph.Identity.DirectoryManagement

<#
    .SYNOPSIS
        Creates a domain
    
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
        Requires Modules Microsoft.Graph.Identity.DirectoryManagement

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/MS%20Graph/Domain

    .Parameter Id
        [sr-en] Identifier of the new domain
        [sr-de] ID der neuen Domäne

    .Parameter IsAdminManaged
        [sr-en] DNS record management of the domain has been delegated to Microsoft 365
        [sr-de] Verwaltung der DNS-Einträge der Domäne wird an Microsoft 365 delegiert

    .Parameter IsDefault
        [sr-en] Is the default domain that is used for user creation
        [sr-de] Standarddomäne für die Erstellung von Benutzern

    .Parameter IsInitial
        [sr-en] Initial domain created by Microsoft Online Services (companyname.onmicrosoft.com)
        [sr-de] Ursprüngliche Domäne, die von Microsoft Online Services erstellt wurde (firmenname.onmicrosoft.com)

    .Parameter IsRoot
        [sr-en] Domain is a verified as root domain
        [sr-de] Als Stammdomäne verifiziert

    .Parameter IsVerified
        [sr-en] Completed domain ownership verification
        [sr-de] Abgeschlossene Überprüfung der Domaininhaberschaft

    .Parameter PasswordNotificationWindowInDays
        [sr-en] Number of days before a user receives notification that their password will expire
        [sr-de] Anzahl der Tage, bevor ein Benutzer eine Benachrichtigung erhält, dass sein Passwort abläuft

    .Parameter PasswordValidityPeriodInDays
        [sr-en] Length of time that a password is valid before it must be changed
        [sr-de] Zeitspanne, die ein Passwort gültig ist
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$Id,
    [switch]$IsAdminManaged,
    [switch]$IsDefault,
    [switch]$IsInitial,
    [switch]$IsRoot,
    [switch]$IsVerified,
    [int]$PasswordNotificationWindowInDays,
    [int]$PasswordValidityPeriodInDays
)

Import-Module Microsoft.Graph.Identity.DirectoryManagement

try{
    ConnectMSGraph 
    [hashtable]$cmdArgs = @{ErrorAction = 'Stop'
                            'Confirm' = $false
                            'Id' = $Id
    }
    if($IsAdminManaged.IsPresent -eq $true){
        $cmdArgs.Add('IsAdminManaged',$IsAdminManaged)
    }
    if($IsDefault.IsPresent -eq $true){
        $cmdArgs.Add('IsDefault',$IsDefault)
    }
    if($IsInitial.IsPresent -eq $true){
        $cmdArgs.Add('IsInitial',$IsInitial)
    }
    if($IsRoot.IsPresent -eq $true){
        $cmdArgs.Add('IsRoot',$IsRoot)
    }
    if($IsVerified.IsPresent -eq $true){
        $cmdArgs.Add('IsVerified',$IsVerified)
    }
    if($PSBoundParameters.ContainsKey('PasswordNotificationWindowInDays') -eq $true){
        $cmdArgs.Add('PasswordNotificationWindowInDays',$PasswordNotificationWindowInDays)
    }
    if($PSBoundParameters.ContainsKey('PasswordValidityPeriodInDays') -eq $true){
        $cmdArgs.Add('PasswordValidityPeriodInDays',$PasswordValidityPeriodInDays)
    }
    $result = New-MgDomain @cmdArgs | Select-Object *

    if($SRXEnv) {
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
    DisconnectMSGraph
}