#Requires -Version 5.0
#Requires -Modules ActiveDirectory

<#
    .SYNOPSIS
        Copy a Active Directory account
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was originally developed for ScriptRunner and has been adapted for a non-ScriptRunner environment.

    .COMPONENT
        Requires Module ActiveDirectory

   .Parameter OUPath
        Specifies the AD path
        [sr-de] Active Directory Pfad

    .Parameter SourceUsername
        Display name, SAMAccountName, DistinguishedName or user principal name of Active Directory user
        [sr-de] Anzeigename, SAMAccountName, Distinguished-Name oder UPN des zu kopierenden Benutzerkontos
    
    .Parameter GivenName
        Specifies the new user's given name
        [sr-de] Gibt den Vornamen des neuen Benutzers an

    .Parameter Surname
        Specifies the new user's last name or surname
        [sr-de] Gibt den Nachnamen des neuen Benutzers an

    .Parameter Password
        Specifies the password value for the new account
        [sr-de] Gibt das Passwort des neuen Benutzers an

    .Parameter DomainAccount
        Active Directory Credential for remote execution without CredSSP
        [sr-de] Active Directory-Benutzerkonto für die Remote-Ausführung ohne CredSSP        

    .Parameter SamAccountName
        Specifies the Security Account Manager (SAM) account name of the new user
        [sr-de] Gibt den SamAccountNamen des neuen Benutzers an

    .Parameter UserPrincipalName
        Specifies the user principal name (UPN) in the format <user>@<DNS-domain-name>.        
        [sr-de] Gibt den UPN des neuen Benutzers an

    .Parameter NewUserName
        Specifies the name of the new user 
        [sr-de] Gibt den Namen des neuen Benutzers an
    
    .Parameter DisplayName
        Specifies the new user's display name
        [sr-de] Gibt den Anzeigenamen des neuen Benutzers an

    .Parameter EmailAddress
        Specifies the user's e-mail address
        [sr-de] Gibt die Mailadresse des neuen Benutzers an

    .Parameter CopyGroupMemberships
        Copies the group memberships too
        [sr-de] Kopiert die Gruppenmitgliedschaften

    .Parameter ChangePasswordAtLogon
        Specifies whether a password must be changed during the next logon attempt
        [sr-de] Gibt an, ob der neue Benutzer das Passwort bei der ersten Anmeldung ändern muss
    
    .Parameter DomainName
        Name of Active Directory Domain
        [sr-de] Name der Active Directory Domäne
        
    .Parameter SearchScope
        Specifies the scope of an Active Directory search
        [sr-de] Gibt den Suchumfang einer Active Directory-Suche an
    
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
    [string]$SourceUsername,
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
    [string]$UserPrincipalName,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [string]$NewUserName,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [string]$DisplayName, 
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [string]$EmailAddress,   
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [switch]$CopyGroupMemberships,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [switch]$ChangePasswordAtLogon,
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
    $Script:CopyProperties =@('AccountExpirationDate','accountExpires','AccountLockoutTime','AccountNotDelegated','AllowReversiblePasswordEncryption','CannotChangePassword','City','co','Company','Country','countryCode','Department','Description','Division', `
                        'DoesNotRequirePreAuth','Enabled','facsimileTelephoneNumber','Fax','HomeDirectory','HomedirRequired','HomeDrive','HomePage','HomePhone','Initials','ipPhone','mail','Manager','MNSLogonAccount','mobile','MobilePhone', `
                        'Office','OfficePhone','Organization','OtherName','pager','PasswordExpired','PasswordNeverExpires','PasswordNotRequired','physicalDeliveryOfficeName','POBox','PostalCode','postOfficeBox','ProtectedFromAccidentalDeletion', `
                        'ScriptPath','SmartcardLogonRequired','st','State','StreetAddress','telephoneNumber','Title','TrustedForDelegation','TrustedToAuthForDelegation','UseDESKeyOnly','wWWHomePage')
    $Script:User 
    $Script:Domain
    [string]$SearchScope='SubTree'

    $Script:Properties =@('GivenName','Surname','SAMAccountName','UserPrincipalname','Name','DisplayName','Description','EmailAddress', 'CannotChangePassword','PasswordNeverExpires' `
                            ,'Department','Company','PostalCode','City','StreetAddress','DistinguishedName')

    if([System.String]::IsNullOrWhiteSpace($SAMAccountName)){
        $SAMAccountName= $GivenName + '.' + $Surname 
    }
    if($SAMAccountName.Length -gt 20){
        $SAMAccountName = $SAMAccountName.Substring(0,20)
    }
    if([System.String]::IsNullOrWhiteSpace($NewUsername)){
        $NewUsername= $GivenName + '_' + $Surname 
    }
    if([System.String]::IsNullOrWhiteSpace($DisplayName)){
        $DisplayName= $GivenName + ', ' + $Surname 
    }
    
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
                'Filter' =  {(SamAccountName -eq $SourceUserName) -or (DisplayName -eq $SourceUserName) -or (DistinguishedName -eq $SourceUserName) -or (UserPrincipalName -eq $SourceUserName)}
                'SearchBase' = $OUPath 
                'SearchScope' = $SearchScope
                'Properties' =  $Script:CopyProperties
                }
    if($null -ne $DomainAccount){
        $cmdArgs.Add("Credential", $DomainAccount)
    }
    $Source= Get-ADUser @cmdArgs

    $cmdArgs = @{'ErrorAction' = 'Stop'
                'Server' = $Domain.PDCEmulator
                'AuthType' = $AuthType
                'Instance' = $Source 
                'Name' = $NewUserName 
                'UserPrincipalName' = $UserPrincipalName 
                'DisplayName' = $DisplayName 
                'GivenName' = $GivenName 
                'Surname' = $Surname 
                'EmailAddress' = $EmailAddress
                'Path' = ($Source.DistinguishedName -split ",",2)[1] 
                'SamAccountName' = $SAMAccountName 
                'AccountPassword' = $Password
                }
    if($null -ne $DomainAccount){
        $cmdArgs.Add("Credential", $DomainAccount)
    }
    $null = New-ADUser @cmdArgs
    Start-Sleep -Seconds 5 # wait
    $cmdArgs = @{'ErrorAction' = 'Stop'
                'Server' = $Domain.PDCEmulator
                'AuthType' = $AuthType
                'Identity' = $SAMAccountName
                }
    if($null -ne $DomainAccount){
        $cmdArgs.Add("Credential", $DomainAccount)
    }
    $Script:User = Get-ADUser @cmdArgs
    
    if($null -ne $Script:User){
        $cmdArgs = @{'ErrorAction' = 'Stop'
                    'Server' = $Domain.PDCEmulator
                    'AuthType' = $AuthType
                    'Identity' = $Script:User.SAMAccountName
                    }
        if($null -ne $DomainAccount){
            $cmdArgs.Add("Credential", $DomainAccount)
        }
        if((-not [System.String]::IsNullOrWhiteSpace($GivenName)) -or(-not [System.String]::IsNullOrWhiteSpace($Surname))){
            $null = Set-ADUser @cmdArgs -GivenName $GivenName -Surname $Surname
        }
        if($ChangePasswordAtLogon -eq $true){
            $null = Set-ADUser @cmdArgs -PasswordNeverExpires $false -ChangePasswordAtLogon $true -CannotChangePassword $false
        }
        if($CopyGroupMemberships){
            $exists = Get-ADPrincipalGroupMembership @cmdArgs
            $cmdArgs.Item("Identity") =  $SourceUsername
            $Groups = Get-ADPrincipalGroupMembership @cmdArgs |  Where-Object SID -ne $exists.SID # remove domain users
            $cmdArgs.Item("Identity") =  $Script:User.SAMAccountName
            if($null -ne $Groups){
                $null = Add-ADPrincipalGroupMembership @cmdArgs -memberOf $Groups
            }
        }
        
        $Script:User = Get-ADUser @cmdArgs -Properties $Script:Properties
        $res = New-Object 'System.Collections.Generic.Dictionary[string,string]'
        $tmp = ($Script:User.DistinguishedName  -split ",",2)[1]
        $res.Add('Path:', $tmp)
        foreach($item in $Script:Properties){
            if(-not [System.String]::IsNullOrWhiteSpace($Script:User[$item])){
                $res.Add($item + ':', $Script:User[$item])
            }
        }
        $Out =@()
        $Out +="User $($GivenName) $($Surname) with follow properties created:"
        $Out +=$res | Format-Table -HideTableHeaders
        Write-Output $Out
    }
    else{
        throw "User $($SourceUserName) not copied"
    }   
}
catch{
    throw
}
finally{
}