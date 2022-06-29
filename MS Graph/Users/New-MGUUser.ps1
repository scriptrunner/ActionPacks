#Requires -Version 5.0
#requires -Modules Microsoft.Graph.Users

<#
    .SYNOPSIS
        Creates a user
    
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
        Requires Modules Microsoft.Graph.Users

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/MS%20Graph/Users

    .Parameter DisplayName
        [sr-en] Users display name
        [sr-de] Anzeigename

    .Parameter UserPrincipalName
        [sr-en] UserPrincipalName
        [sr-de] UserPrincipalName

    .Parameter AccountEnabled
        [sr-en] Account enabled
        [sr-de] Konto aktiviert

    .PARAMETER AgeGroup
        [sr-en] Age group of the user
        [sr-de] Altersgruppe des Benutzers
        
    .PARAMETER Birthday
        [sr-en] Users birthday
        [sr-de] Geburtstag des Benutzers

    .PARAMETER BusinessPhone
        [sr-en] Telephone number
        [sr-de] Telefonnummer

    .PARAMETER City
        [sr-en] City
        [sr-de] Stadt        

    .PARAMETER CompanyName
        [sr-en] Company
        [sr-de] Unternehmen     

    .PARAMETER Country
        [sr-en] Country
        [sr-de] Land     

    .PARAMETER Department
        [sr-en] Department
        [sr-de] Abteilung   

    .PARAMETER EmployeeId
        [sr-en] EmployeeId
        [sr-de] Arbeitnehmer ID

    .PARAMETER FaxNumber
        [sr-en] Fax number
        [sr-de] Fax Nummer

    .PARAMETER GivenName
        [sr-en] Given name
        [sr-de] Vorname

    .PARAMETER Surname
        [sr-en] Surname
        [sr-de] Nachname

    .PARAMETER JobTitle
        [sr-en] Job title
        [sr-de] Berufsbezeichnung

    .PARAMETER Mail
        [sr-en] Mail
        [sr-de] E-Mail

    .PARAMETER MailNickname
        [sr-en] Mail nickname
        [sr-de] E-Mail Alias

    .PARAMETER Manager
        [sr-en] Manager
        [sr-de] Vorgesetzter

    .PARAMETER MobilePhone
        [sr-en] Mobile number
        [sr-de] Mobile Telefonnummer

    .PARAMETER Password
        [sr-en] Initial password
        [sr-de] Initiales Kennwort

    .PARAMETER PostalCode
        [sr-en] Postal code
        [sr-de] Postleitzahl

    .PARAMETER ShowInAddressList
        [sr-en] Show user in Outlook global address list
        [sr-de] In globaler Adressliste anzeigen

    .PARAMETER State
        [sr-en] State
        [sr-de] Staat

    .PARAMETER StreetAddress
        [sr-en] Street
        [sr-de] Strassse
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$DisplayName,
    [Parameter(Mandatory = $true,HelpMessage="ASRDisplay(Password)")]
    [string]$Password,
    [Parameter(Mandatory = $true)]
    [string]$UserPrincipalName,
    [Parameter(Mandatory = $true)]
    [string]$MailNickname,
    [switch]$AccountEnabled,
    [ValidateSet('Minor','NotAdult','Adult')]
    [string]$AgeGroup,
    [datetime]$Birthday,
    [string]$BusinessPhone,
    [string]$City,
    [string]$CompanyName,
    [string]$Country,
    [string]$Department,
    [string]$EmployeeId,
    [string]$FaxNumber,
    [string]$GivenName,
    [string]$Surname,
    [string]$JobTitle,
    [string]$Mail,
    [string]$Manager,
    [string]$MobilePhone,
    [string]$PostalCode,
    [switch]$ShowInAddressList,
    [string]$State,
    [string]$StreetAddress
)

Import-Module Microsoft.Graph.Users

try{
    [string[]]$Properties = @('DisplayName','Id','GivenName','Surname','Mail','PostalCode','City','StreetAddress','CompanyName','Country','Department','AccountEnabled','LastPasswordChangeDateTime','CreatedDateTime','DeletedDateTime')
    ConnectMSGraph 
    [hashtable]$cmdArgs = @{ErrorAction = 'Stop'
                        'Confirm' = $false
                        'AccountEnabled' = $AccountEnabled
                        'ShowInAddressList' = $ShowInAddressList
                        'DisplayName' = $DisplayName
                        'UserPrincipalName' = $UserPrincipalName
                        'PasswordProfile' = @{'Password' = $Password}
                        'MailNickname' = $MailNickname
    }
    if($PSBoundParameters.ContainsKey('AgeGroup') -eq $true){
        $cmdArgs.Add('AgeGroup',$AgeGroup)
    }
    if($PSBoundParameters.ContainsKey('BusinessPhone') -eq $true){
        $cmdArgs.Add('BusinessPhones',@($BusinessPhone))
    }
    if($PSBoundParameters.ContainsKey('City') -eq $true){
        $cmdArgs.Add('City',$City)
    }
    if($PSBoundParameters.ContainsKey('CompanyName') -eq $true){
        $cmdArgs.Add('CompanyName',$CompanyName)
    }
    if($PSBoundParameters.ContainsKey('Country') -eq $true){
        $cmdArgs.Add('Country',$Country)
    }
    if($PSBoundParameters.ContainsKey('Department') -eq $true){
        $cmdArgs.Add('Department',$Department)
    }
    if($PSBoundParameters.ContainsKey('EmployeeId') -eq $true){
        $cmdArgs.Add('EmployeeId',$EmployeeId)
    }
    if($PSBoundParameters.ContainsKey('FaxNumber') -eq $true){
        $cmdArgs.Add('FaxNumber',$FaxNumber)
    }
    if($PSBoundParameters.ContainsKey('GivenName') -eq $true){
        $cmdArgs.Add('GivenName',$GivenName)
    }
    if($PSBoundParameters.ContainsKey('Surname') -eq $true){
        $cmdArgs.Add('Surname',$Surname)
    }
    if($PSBoundParameters.ContainsKey('JobTitle') -eq $true){
        $cmdArgs.Add('JobTitle',$JobTitle)
    }
    if($PSBoundParameters.ContainsKey('Mail') -eq $true){
        $cmdArgs.Add('Mail',$Mail)
    }
    if($PSBoundParameters.ContainsKey('Manager') -eq $true){
        $cmdArgs.Add('Manager',$Manager)
    }
    if($PSBoundParameters.ContainsKey('MobilePhone') -eq $true){
        $cmdArgs.Add('MobilePhone',$MobilePhone)
    }
    if($PSBoundParameters.ContainsKey('PostalCode') -eq $true){
        $cmdArgs.Add('PostalCode',$PostalCode)
    }
    if($PSBoundParameters.ContainsKey('State') -eq $true){
        $cmdArgs.Add('State',$State)
    }
    if($PSBoundParameters.ContainsKey('StreetAddress') -eq $true){
        $cmdArgs.Add('StreetAddress',$StreetAddress)
    }
    $result = New-MgUser @cmdArgs | Select-Object $Properties

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