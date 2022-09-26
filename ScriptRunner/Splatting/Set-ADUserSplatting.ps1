<#
.Synopsis
.Description
.Notes
.Component
.Parameter UserIdentity
    Nimmt einen AD-Benutzer aus einer Query
.Parameter PostalCode
    zeigt die PLZ eines AD-Benutzers
.Parameter GivenName
    zeigt den Vornamen eines AD-Benutzers
.Parameter sn
    zeigt den Nachnamen eines AD-Benutzers
.Parameter streetAddress
    zeigt die Straße eines AD-Benutzers
#>


param (
    [Parameter(Mandatory = $true, HelpMessage = "ASRDisplay(Splatting)")] #Notwendig damit die Attribute der $UserIdentity im Script verwendet werden können 
    [hashtable]$UserIdentity,
    [string]$PostalCode,
    [string]$GivenName,
    [string]$sn,
    [pscredential]$cred    
)

Import-Module ActiveDirectory

try {
    [hashtable]$Properties = @{
        'Identity' = $UserIdentity.sAMAccountName #Hier wird mittels Splatting der sAMAccountName aus dem Parameter (Hashtable) $UserIdentity verwendet
        'PostalCode' = $PostalCode
        'GivenName' = $GivenName
        'sn' = $sn
    }

    Set-ADUser @Properties #Mittels Splatting werden die Attribute des AD Benutzers gesetzt
}
catch {
    throw
}