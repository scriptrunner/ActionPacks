#Requires -Version 5.0

<#
    .SYNOPSIS
        Sample script of a onboarding process
    
    .DESCRIPTION          

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires Module ActiveDirectory,AzureAD,MicrosoftTeams
        Requires Library script OnOffBoardingLib.ps1

    .LINK            
        
    .Parameter O365Account
        Credential to connect Azure Active Directory
        
    .Parameter ADAccount
        Active Directory Credential for remote execution without CredSSP

    .Parameter ADSourceUser
        SAMAccountName, DistinguishedName or user principal name of the source Active Directory user
        The new users will be assigned the group memberships of this user
 
    .Parameter ADPassword
        Specifies the initial password for the Active Directory accounts
 
    .Parameter O365Password
        Specifies the initial password for the O365 accounts

    .Parameter ADCsvFile
        Specifies the path and filename of the CSV file to import users in Active Directory

    .Parameter O365CsvFile
        Specifies the path and filename of the CSV file to import users in O365

    .Parameter Delimiter
        Specifies the delimiter that separates the property values in the CSV file

    .Parameter FileEncoding
        Specifies the type of character encoding that was used in the CSV file

    .Parameter ADGroups
        Specifies the Active Directory groups to which the users added

    .Parameter O365Teams
        Specifies the display names of the Teams to which the users added

    .Parameter ChangePasswordAtLogon
        Specifies whether a password must be changed during the next logon attempt

    .Parameter CannotChangePassword
        Specifies whether the account password can be changed

    .Parameter PasswordNeverExpires
        Specifies whether the password of an account can expire

    .Parameter O365ForceChangePasswordNextLogin
        Forces a user to change their password during their next log iny

    .Parameter O365ShowInAddressList 
        Specifies show this user in the address list

    .Parameter O365Licenses
        Specifies a list of license SkuIDs to assign to the users, comma separated

    .Parameter ExchangeAccount
        Credential with sufficient permissions on Microsoft Exchange Server

    .Parameter ExchangeServerFQDN
        Specifies the Fully Qualified Domain Name of the Microsoft Exchange Server          
 
    .Parameter ExchangePassword
        Specifies the initial password for the Exchange Mailbox
 
    .Parameter ADPassword
        Specifies the initial password for the Active Directory accounts

    .Parameter ExchangeDistributionGroups
        Specifies the names or display names of the Distribution groups to add to the users, comma separated

    .Parameter DomainName
        Name of Active Directory Domain

    .Parameter AzureDomain
        Name of Azure Domain e.g. Contoso.com
    
    .Parameter ADAuthType
        Specifies the authentication method to use

    .Parameter O365Tenant
        Specifies the ID of a O365 tenant        
        
    .Parameter MSTeamsAccount
        MSTeams Credential

    .Parameter MSTeamsTenant
        Specifies the ID of a Teams tenant
#>

param( 
    [Parameter(Mandatory=$true)]
    [string]$ADCsvFile,
    [Parameter(Mandatory=$true)]
    [string]$O365CsvFile,
    [Parameter(Mandatory=$true)]
    [securestring]$ADPassword,  
    [Parameter(Mandatory=$true)]
    [securestring]$O365Password,  
    [Parameter(Mandatory =$true)]   
    [PSCredential]$O365Account,
    [Parameter(Mandatory =$true)]   
    [string]$AzureDomain, 
    [string]$ADSourceUser,
    [string[]]$ADGroups, 
    [string[]]$O365Teams, 
    [string]$O365Licenses,
    [switch]$ChangePasswordAtLogon,  
    [switch]$CannotChangePassword,
    [switch]$PasswordNeverExpires,
    [bool]$O365ForceChangePasswordNextLogin,
    [bool]$O365ShowInAddressList,
    [PSCredential]$ExchangeAccount,
    [string]$ExchangeServerFQDN,
    [securestring]$ExchangePassword,  
    [string]$ExchangeDistributionGroups,
    [string]$Delimiter= ';',
    [ValidateSet('Unicode','UTF7','UTF8','ASCII','UTF32','BigEndianUnicode','Default','OEM')]
    [string]$FileEncoding = 'UTF8',   
    [string]$DomainName,
    [PSCredential]$ADAccount, 
    [ValidateSet('Basic', 'Negotiate')]
    [string]$ADAuthType = "Negotiate", 
    [string]$O365Tenant,
    [PSCredential]$MSTeamsAccount,
    [string]$MSTeamsTenant
)

Import-Module ActiveDirectory,AzureAD,MicrosoftTeams

try{
    $user = $null
    [string[]]$output = @()
    # Create users in Active Directory
    if(Test-Path -Path $ADCsvFile -ErrorAction SilentlyContinue){
        $users = Import-Csv -Path $ADCsvFile -Delimiter $Delimiter -Encoding $FileEncoding -ErrorAction Stop `
            -Header @('LastName', 'FirstName', 'SAMAccountName', 'UserPrincipalname','UserName', 'DisplayName', 'Description',
                        'EmailAddress','Department','Company','PostalCode','City','Street','OUPath',
                        'CreateMailbox','ActivateActiveSync') 
        }
    else{
        Throw "$($ADCsvFile) does not exist"
    }    
    if($null -eq $ExchangePassword){
        $ExchangePassword = $ADPassword
    }
    foreach($item in $users){        
        if(($item.LastName -eq 'LastName')-or ([System.String]::IsNullOrWhiteSpace($item.LastName) -eq $true)){
            continue
        }
        # create user in Active Directory
        CreateUserInAD -User ([ref] $user) -OUPath $item.OUPath -Password $ADPassword -ADCredential $ADAccount -DomainName $DomainName `
                -Surname $item.LastName -GivenName $item.FirstName -SAMAccountName $item.SAMAccountName -Description $item.Description `
                -PasswordNeverExpires:$PasswordNeverExpires -ChangePasswordAtLogon:$ChangePasswordAtLogon -CannotChangePassword:$CannotChangePassword `
                -UserPrincipalname $item.UserPrincipalname -DisplayName $item.DisplayName -UserName $item.UserName `
                -Street $item.Street -City $item.City -PostalCode $item.PostalCode -Company $item.Company `
                -EmailAddress $item.EmailAddress -Department $item.Department  -AuthType $ADAuthType
        $output += "User $($item.LastName) $($item.FirstName) created in Active Directory"
        # group memberships
        if([System.String]::IsNullOrWhiteSpace($ADSourceUser) -eq $false){
            CopyADMemberships -SourceUserName $ADSourceUser -TargetUserName $user.SAMAccountName -DomainName $DomainName -ADCredential $ADAccount -AuthType $ADAuthType
            $output += "Active Directory groups copied from User $($ADSourceUser) to User $($item.LastName) $($item.FirstName)"
        }
        if(($null -ne $ADGroups) -and ($ADGroups.Length -gt 0)){
            AddUserToADGroups -UserName $user.SAMAccountName -Groups $ADGroups -DomainName $DomainName -ADCredential $ADAccount -AuthType $ADAuthType
            $output += "User $($item.LastName) $($item.FirstName) assigned to Active Directory groups"
        }        
        if($item.CreateMailbox -eq '1') {
            if(($null -ne $ExchangeAccount) -and ([System.String]::IsNullOrWhiteSpace($ExchangeServerFQDN) -eq $false)){
                $box = $null
                CreateExchangeMailbox -Mailbox ([ref]$box) -UserName $user.SAMAccountName -ActivateActiveSync ($item.ActivateActiveSync -eq '1') -ExCredential $ExchangeAccount -ServerName $ExchangeServerFQDN
                $output += "User $($item.LastName) $($item.FirstName) Mailbox $($box.WindowsEmailAddress) created"                
            }
            else{
                $output += "User $($item.LastName) $($item.FirstName) can´t create Mailbox. Missing Parameters"
            }
        }
        # Exchange Address lists
        if($null -ne $ExchangeDistributionGroups){
            AddUserToExchangeDistributionGroups -UserName $user.SAMAccountName -Groups ($ExchangeDistributionGroups.Split(',')) -ExCredential $ExchangeAccount -ServerName $ExchangeServerFQDN
            $output += "Exchange: User $($item.LastName) $($item.FirstName) assigned to Distribution groups"
        }
    }
    # Create users in O365
    if(Test-Path -Path $O365CsvFile -ErrorAction SilentlyContinue){
        $users = Import-Csv -Path $O365CsvFile -Delimiter $Delimiter -Encoding $FileEncoding -ErrorAction Stop `
            -Header @('UserName','DisplayName','LastName','FirstName','MailNickName','PostalCode','City','Street','PhoneNumber','MobilePhone','Department','Enabled','MemberType','LicenseSkuIds') 
        # Create user in Azure AD
        [string]$o365Domain = '@' + $AzureDomain
        [bool]$userEnabled = $true
        [string]$memberType
        foreach($item in $users){        
            if(($item.UserName -eq 'UserName')-or ([System.String]::IsNullOrWhiteSpace($item.UserName) -eq $true)){
                continue
            }
            $tmp = $Item.UserName + $o365Domain
            $memberType = 'Member'
            $userEnabled = $true
            if ($item.MemberType -like 'guest') {
                $memberType = 'Guest'
            }
            if ($item.Enabled -eq '0') {
                $userEnabled = $false
            }
            CreateUserInO365 -User ([ref] $user) -O365Credential $O365Account -Password $O365Password -UserPrincipalName $tmp `
                            -DisplayName $item.DisplayName -FirstName $item.FirstName -MailNickName $item.MailNickName -ForceChangePasswordNextLogin $O365ForceChangePasswordNextLogin `
                            -LastName $item.LastName -PostalCode $item.PostalCode -City $item.City -Street $item.Street `
                            -PhoneNumber $item.PhoneNumber -MobilePhone $item.MobilePhone -Department $item.Department `
                            -Enabled $userEnabled -UserType $memberType -ShowInAddressList $O365ShowInAddressList -Tenant $O365Tenant
            $output += "O365 User $($item.UserName) created in O365"
            # Teams memberships     
            if(($null -ne $O365Teams) -and ($O365Teams.Length -gt 0)){
                if($null -eq $MSTeamsAccount){
                    $MSTeamsAccount = $O365Account
                }
                if([System.String]::IsNullOrWhiteSpace($MSTeamsTenant) -eq $true){
                    $MSTeamsTenant = $Tenant
                } 
                AddO365UserToTeams -UserName $tmp -Teams $O365Teams -TeamsCredential $MSTeamsAccount -TeamsTenant $MSTeamsTenant
                $output += "User $($item.UserName) assigned to Teams"
    
            }
            # Licenses
            if(($null -ne $O365Licenses) -and ($O365Licenses.Length -gt 0)){
                AddO365LicensesToUser -UserName $tmp -Licenses ($O365Licenses.Split(',')) -O365Credential $O365Account -Tenant $O365Tenant
                $output += "User $($item.UserName) common licenses assigned"
            }
            if([System.String]::IsNullOrWhiteSpace($item.LicenseSkuIds) -eq $false){
                AddO365LicensesToUser -UserName $tmp -Licenses ($item.LicenseSkuIds.Split(',')) -O365Credential $O365Account -Tenant $O365Tenant
                $output += "User $($item.UserName) licenses assigned"
            }

            $user = $null
        }
    }
    else{
        Throw "$($O365CsvFile) does not exist"
    }

    if($SRXEnv) {
        $SRXEnv.ResultMessage = $output
    } 
    else {
        Write-Output $output
    }
}
catch{
    Write-Output $_.exception.message
    throw 
}
finally{
    
}