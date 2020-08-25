#Requires -Version 4.0
#Requires -Modules ActiveDirectory

<#
    .SYNOPSIS
        Creates a user in the OU path
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires Module ActiveDirectory
        ScriptRunner Version 4.2.x or higher

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/ActiveDirectory/Users

    .Parameter OUPath
        Specifies the AD path
        [sr-de] Active Directory Pfad

    .Parameter GivenName
        Specifies the user's given name
        [sr-de] Gibt den Vornamen des Benutzers an

    .Parameter Surname
        Specifies the user's last name or surname
        [sr-de] Gibt den Nachnamen des Benutzers an

    .Parameter Password
        Specifies a new password value for an account
        [sr-de] Gibt das initiale Passwort des Benutzers an

    .Parameter DomainAccount    
        Active Directory Credential for remote execution without CredSSP
        [sr-de] Active Directory-Benutzerkonto für die Remote-Ausführung ohne CredSSP        

    .Parameter SAMAccountName
        Specifies the Security Account Manager (SAM) account name of the user
        [sr-de] Gibt der SAMAccountName des Benutzers an

    .Parameter UserPrincipalname
        Specifies the user principal name (UPN) in the format <user>@<DNS-domain-name>
        [sr-de] Gibt den UPN des Benutzers an
        
    .Parameter UserName
        Specifies the name of the new user
        [sr-de] Gibt den Namen des Benutzers an

    .Parameter DisplayName
        Specifies the display name of the user
        [sr-de] Gibt den Anzeigenamen des Benutzers an
    
    .Parameter Description
        Specifies a description of the user
        [sr-de] Gibt die Beschreibung des Benutzers an

    .Parameter EmailAddress
        Specifies the user's e-mail address
        [sr-de] Gibt die Mailadresse des Benutzers an

    .Parameter CannotChangePassword
        Specifies whether the account password can be changed
        [sr-de] Gibt an, ob der Benutzer das Passwort ändern kann

    .Parameter PasswordNeverExpires
        Specifies whether the password of an account can expire
        [sr-de] Gibt an, ob das Passwort nie abläuft

    .Parameter ChangePasswordAtLogon
        Specifies whether a password must be changed during the next logon attempt
        [sr-de] Gibt an, ob der Benutzer das Passwort bei der ersten Anmeldung ändern muss

    .Parameter Department
        Specifies the user's department
        [sr-de] Gibt die Abteilung des Benutzers an

    .Parameter Company
        Specifies the user's company
        [sr-de] Gibt die Firma des Benutzers an

    .Parameter PostalCode
        Specifies the user's postal code or zip code
        [sr-de] Gibt die Postleitzahl des Benutzers an

    .Parameter City
        Specifies the user's town or city
        [sr-de] Gibt den Ort des Benutzers an

    .Parameter Street
        Specifies the user's street address
        [sr-de] Gibt die Strasse des Benutzers an

    .Parameter DomainName
        Name of Active Directory Domain
        [sr-de] Name der Active Directory Domäne
    
    .Parameter AuthType
        Specifies the authentication method to use
        [sr-de] Gibt die zu verwendende Authentifizierungsmethode an
#>

param(    
    [Parameter(Mandatory = $true,ParameterSetName = "Local or Remote DC")]
    [Parameter(Mandatory = $true,ParameterSetName = "Remote Jumphost")]
    [string]$OUPath,   
    [Parameter(Mandatory = $true,ParameterSetName = "Local or Remote DC")]
    [Parameter(Mandatory = $true,ParameterSetName = "Remote Jumphost")]
    [string]$GivenName,
    [Parameter(Mandatory = $true,ParameterSetName = "Local or Remote DC")]
    [Parameter(Mandatory = $true,ParameterSetName = "Remote Jumphost")]
    [string]$Surname,
    [Parameter(Mandatory = $true,ParameterSetName = "Local or Remote DC")]
    [Parameter(Mandatory = $true,ParameterSetName = "Remote Jumphost")]
    [securestring]$Password,
    [Parameter(Mandatory = $true,ParameterSetName = "Remote Jumphost")]
    [PSCredential]$DomainAccount,    
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [string]$SAMAccountName,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [string]$UserPrincipalname,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [string]$Username,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [string]$DisplayName,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [string]$Description,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [string]$EmailAddress,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [switch]$ChangePasswordAtLogon,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [switch]$CannotChangePassword,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [switch]$PasswordNeverExpires,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [string]$Department,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [string]$Company,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [string]$PostalCode,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [string]$City,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [string]$Street,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [string]$DomainName,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [ValidateSet('Basic', 'Negotiate')]
    [string]$AuthType="Negotiate"
)

Import-Module ActiveDirectory

try{
    $Script:User 
    $Script:Domain
    $Script:Properties = @('GivenName','Surname','SAMAccountName','UserPrincipalname','Name','DisplayName','Description','EmailAddress', 'CannotChangePassword','PasswordNeverExpires' `
                            ,'Department','Company','PostalCode','City','StreetAddress','DistinguishedName')

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'AuthType' = $AuthType
                            }
    if($null -ne $DomainAccount){
        $cmdArgs.Add("Credential", $DomainAccount)
    }
    if([System.String]::IsNullOrWhiteSpace($DomainName)){
        $cmdArgs.Add("Current", 'LocalComputer')
    }
    else {
        $cmdArgs.Add("Identity", $DomainName)
    }
    $Domain = Get-ADDomain @cmdArgs

    if([System.String]::IsNullOrWhiteSpace($SAMAccountName)){
        $SAMAccountName= $GivenName + '.' + $Surname 
    }
    if($SAMAccountName.Length -gt 20){
        $SAMAccountName = $SAMAccountName.Substring(0,20)
    }
    if([System.String]::IsNullOrWhiteSpace($Username)){
        $Username = $GivenName + '_' + $Surname 
    }
    if([System.String]::IsNullOrWhiteSpace($DisplayName)){
        $DisplayName = $GivenName + ', ' + $Surname 
    }
    if([System.String]::IsNullOrWhiteSpace($UserPrincipalName)){
        $UserPrincipalName = "$($GivenName).$($Surname)@$($Domain.DNSRoot)"
    }
    elseif($UserPrincipalName.StartsWith('@')){
        $UserPrincipalName = $GivenName + '.' + $Surname + $UserPrincipalName
    }
    if([System.String]::IsNullOrWhiteSpace($EmailAddress)){
        $EmailAddress = "$($GivenName).$($Surname)@$($Domain.DNSRoot)"
    }
    elseif($EmailAddress.StartsWith('@')){
        $EmailAddress = $GivenName + '.' + $Surname + $EmailAddress
    }
    $cmdArgs = @{'ErrorAction' = 'Stop'
                'Server' = $Domain.PDCEmulator
                'AuthType' = $AuthType
                'Name' = $UserName 
                'UserPrincipalName' = $UserPrincipalName 
                'DisplayName' = $DisplayName 
                'GivenName' = $GivenName 
                'Surname' = $Surname 
                'EmailAddress' = $EmailAddress
                'Path' = $OUPath
                'SamAccountName' = $SAMAccountName 
                'AccountPassword' = $Password
                'Confirm' = $false
                'Description' = $Description
                'Department' = $Department 
                'Company' = $Company 
                'City' = $City
                'PostalCode' = $PostalCode
                'ChangePasswordAtLogon' = $ChangePasswordAtLogon.ToBool()
                'PasswordNeverExpires' = $PasswordNeverExpires.ToBool() 
                'CannotChangePassword' = $CannotChangePassword.ToBool()
                'StreetAddress' = $Street 
                'Enable' = $true 
                'PassThru' = $null
                }
    if($null -ne $DomainAccount){
        $cmdArgs.Add("Credential", $DomainAccount)
    }
    $Script:User = New-ADUser @cmdArgs

    if($Script:User){
        Start-Sleep -Seconds 5 # wait
        $cmdArgs = @{'ErrorAction' = 'Stop'
                    'Server' = $Domain.PDCEmulator
                    'AuthType' = $AuthType
                    'Identity' = $SAMAccountName
                    'Properties' = $Script:Properties
                    }
        if($null -ne $DomainAccount){
            $cmdArgs.Add("Credential", $DomainAccount)
        }
        $Script:User = Get-ADUser @cmdArgs
        
        $res=New-Object 'System.Collections.Generic.Dictionary[string,string]'
        $tmp=($Script:User.DistinguishedName  -split ",",2)[1]
        $res.Add('Path:', $tmp)
        foreach($item in $Script:Properties){
            if(-not [System.String]::IsNullOrWhiteSpace($Script:User[$item])){
                $res.Add($item + ':', $Script:User[$item])
            }
        }
        $Out =@()
        $Out +="User $($GivenName) $($Surname) with follow properties created:"
        $Out +=$res | Format-Table -HideTableHeaders
        if($SRXEnv) {
            $SRXEnv.ResultMessage = $Out
        }
        else {
            Write-Output $Out 
        }    
    }    
}
catch{
    throw
}
finally{
}