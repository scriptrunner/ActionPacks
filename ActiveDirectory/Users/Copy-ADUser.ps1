#Requires -Version 4.0
#Requires -Modules ActiveDirectory

<#
    .SYNOPSIS
        Copy a Active Directory account
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, AppSphere AG assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of AppSphere AG.
        © AppSphere AG

    .COMPONENT
        Requires Module ActiveDirectory
        ScriptRunner Version 4.2.x or higher

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/ActiveDirectory/Users

    .Parameter OUPath
        Specifies the AD path

    .Parameter SourceUsername
        Display name, SAMAccountName, DistinguishedName or user principal name of Active Directory user
    
    .Parameter GivenName
        Specifies the new user's given name

    .Parameter Surname
        Specifies the new user's last name or surname

    .Parameter Password
        Specifies the password value for the new account

    .Parameter DomainAccount
        Active Directory Credential for remote execution without CredSSP

    .Parameter SamAccountName
        Specifies the Security Account Manager (SAM) account name of the new user

    .Parameter UserPrincipalName
        Specifies the user principal name (UPN) in the format <user>@<DNS-domain-name>.

    .Parameter NewUserName
        Specifies the name of the new user 
    
    .Parameter DisplayName
        Specifies the new user's display name

    .Parameter EmailAddress
        Specifies the user's e-mail address

    .Parameter CopyGroupMemberships
        Copies the group memberships too

    .Parameter ChangePasswordAtLogon
        Specifies whether a password must be changed during the next logon attempt
    
    .Parameter DomainName
        Name of Active Directory Domain
        
    .Parameter SearchScope
        Specifies the scope of an Active Directory search

    .Parameter AuthType
        Specifies the authentication method to use
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
    if($UserPrincipalName.StartsWith('@')){
        $UserPrincipalName = $GivenName + '.' + $Surname + $UserPrincipalName
    }
    if($EmailAddress.StartsWith('@')){
    $EmailAddress = $GivenName + '.' + $Surname + $EmailAddress
    }
    if($PSCmdlet.ParameterSetName  -eq "Remote Jumphost"){
        if([System.String]::IsNullOrWhiteSpace($DomainName)){
            $Script:Domain = Get-ADDomain -Current LocalComputer -AuthType $AuthType -Credential $DomainAccount  -ErrorAction Stop
        }
        else{
            $Script:Domain = Get-ADDomain -Identity $DomainName -AuthType $AuthType -Credential $DomainAccount  -ErrorAction Stop
        }
        $Source= Get-ADUser -Server $Script:Domain.PDCEmulator -Credential $DomainAccount -AuthType $AuthType `
            -Filter {(SamAccountName -eq $SourceUserName) -or (DisplayName -eq $SourceUserName) -or (DistinguishedName -eq $SourceUserName) -or (UserPrincipalName -eq $SourceUserName)} `
            -SearchBase $OUPath -SearchScope $SearchScope `
            -Properties $Script:CopyProperties -ErrorAction Stop
        New-ADUser -Server $Script:Domain.PDCEmulator -Credential $DomainAccount -AuthType $AuthType `
            -Instance $Source -Name $NewUserName -UserPrincipalName $UserPrincipalName -DisplayName $DisplayName `
            -GivenName $GivenName -Surname $Surname -EmailAddress $EmailAddress `
            -Path ($Source.DistinguishedName -split ",",2)[1] -SamAccountName $SAMAccountName -AccountPassword $Password -ErrorAction Stop
        Start-Sleep -Seconds 5 # wait
        $Script:User=Get-ADUser -Server $Script:Domain.PDCEmulator -Credential $DomainAccount -AuthType $AuthType -Identity $SAMAccountName -ErrorAction Stop
    }
    else{
        if([System.String]::IsNullOrWhiteSpace($DomainName)){
            $Script:Domain = Get-ADDomain -Current LocalComputer -AuthType $AuthType  -ErrorAction Stop
        }
        else{
            $Script:Domain = Get-ADDomain -Identity $DomainName -AuthType $AuthType  -ErrorAction Stop
        }
        $Source= Get-ADUser -Server $Script:Domain.PDCEmulator -AuthType $AuthType `
            -SearchBase $OUPath -SearchScope $SearchScope `
            -Filter {(SamAccountName -eq $SourceUserName) -or (DisplayName -eq $SourceUserName) -or (DistinguishedName -eq $SourceUserName) -or (UserPrincipalName -eq $SourceUserName)} `
            -Properties $Script:CopyProperties -ErrorAction Stop
        New-ADUser -Server $Script:Domain.PDCEmulator -AuthType $AuthType `
            -Instance $Source -Name $NewUserName -DisplayName $DisplayName -SamAccountName $SAMAccountName `
            -GivenName $GivenName -Surname $Surname -EmailAddress $EmailAddress `
            -Path ($Source.DistinguishedName -split ",",2)[1] -UserPrincipalName $UserPrincipalName -AccountPassword $Password -ErrorAction Stop
        Start-Sleep -Seconds 5 # wait
        $Script:User=Get-ADUser -Server $Script:Domain.PDCEmulator -AuthType $AuthType -Identity $SAMAccountName -ErrorAction Stop
    }
    if($null -ne $Script:User){
        if($PSCmdlet.ParameterSetName  -eq "Remote Jumphost"){
            if((-not [System.String]::IsNullOrWhiteSpace($GivenName)) -or(-not [System.String]::IsNullOrWhiteSpace($Surname))){
                Set-ADUser -Credential $DomainAccount -Server $Script:Domain.PDCEmulator -AuthType $AuthType -Identity $Script:User.SAMAccountName -GivenName $GivenName -Surname $Surname
            }
            if($ChangePasswordAtLogon -eq $true){
                Set-ADUser -PasswordNeverExpires $false -ChangePasswordAtLogon $true -CannotChangePassword $false -Credential $DomainAccount -Server $Script:Domain.PDCEmulator -AuthType $AuthType -Identity $Script:User.SAMAccountName
            }
            if($CopyGroupMemberships){
                $exists = Get-ADPrincipalGroupMembership -Credential $DomainAccount -Server $Script:Domain.PDCEmulator -AuthType $AuthType -Identity $Script:User.SAMAccountName
                $Groups = Get-ADPrincipalGroupMembership -Credential $DomainAccount -Server $Script:Domain.PDCEmulator -AuthType $AuthType -Identity $SourceUsername `
                        |  Where-Object SID -ne $exists.SID # remove domain users
                if($null -ne $Groups){
                    Add-ADPrincipalGroupMembership -Credential $DomainAccount -Server $Script:Domain.PDCEmulator -AuthType $AuthType -Identity $Script:User.SAMAccountName -memberOf $Groups
                }
            }
        }
        else {
            if((-not [System.String]::IsNullOrWhiteSpace($GivenName)) -or(-not [System.String]::IsNullOrWhiteSpace($Surname))){
                Set-ADUser -Server $Script:Domain.PDCEmulator -AuthType $AuthType -Identity $Script:User.SAMAccountName -GivenName $GivenName -Surname $Surname
            }
            if($ChangePasswordAtLogon -eq $true){
                Set-ADUser -PasswordNeverExpires $false -ChangePasswordAtLogon $true -CannotChangePassword $false -Server $Script:Domain.PDCEmulator -AuthType $AuthType -Identity $Script:User.SAMAccountName
            }
            if($CopyGroupMemberships){
                $exists = Get-ADPrincipalGroupMembership -Server $Script:Domain.PDCEmulator -AuthType $AuthType -Identity $Script:User.SAMAccountName
                $Groups = Get-ADPrincipalGroupMembership -Server $Script:Domain.PDCEmulator -AuthType $AuthType -Identity $SourceUsername `
                        |  Where-Object SID -ne $exists.SID # remove domain users
                if($null -ne $Groups){
                    Add-ADPrincipalGroupMembership -Server $Script:Domain.PDCEmulator -AuthType $AuthType -Identity $Script:User.SAMAccountName -memberOf $Groups
                }
            }
        }
        if($PSCmdlet.ParameterSetName  -eq "Remote Jumphost"){
            $Script:User = Get-ADUser -Identity $Script:User.SAMAccountName -Properties $Script:Properties -Credential $DomainAccount -AuthType $AuthType -Server $Script:Domain.PDCEmulator
        }
        else{
            $Script:User = Get-ADUser -Identity $Script:User.SAMAccountName -Properties $Script:Properties -AuthType $AuthType -Server $Script:Domain.PDCEmulator
        }
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
    else{
        if($SRXEnv) {
            $SRXEnv.ResultMessage = "User $($SourceUserName) not copied"
        }    
        Throw "User $($SourceUserName) not copied"
    }   
}
catch{
    throw
}
finally{
}