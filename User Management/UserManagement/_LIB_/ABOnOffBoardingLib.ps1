#Requires -Version 5.0

function ConnectDomain{
    <#
        .SYNOPSIS
            Connects the domain    

        .COMPONENT
            Requires Module ActiveDirectory    

        .Parameter DomainAccount
            Active Directory Credential for remote execution without CredSSP        

        .Parameter DomainName
            Name of Active Directory Domain

        .Parameter AuthType
            Specifies the authentication method to use

        .Parameter Domain
            Reference parameter for result
    #>

    param (
        [string]$DomainName,
        [PSCredential]$DomainAccount,
        [ValidateSet('Basic', 'Negotiate')]
        [string]$AuthType = "Negotiate" ,
        [ref]$Domain  
    )
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
    $Domain.Value = Get-ADDomain @cmdArgs
}
function ConnectAzureAD {
    <#
        .SYNOPSIS
            Connects the Azure Active Directory    

        .COMPONENT
            Requires Module AzureAD    

        .Parameter AzureCredential
            Credential for connect Azure Active Directory       

        .Parameter TenantID
            Specifies the ID of a tenant
    #>

    param (
        [pscredential]$AzureCredential,
        [string]$TenantID
    )
    
    try{
        if([System.String]::IsNullOrWhiteSpace($TenantID) -eq $false){
            $null = Connect-AzureAD -Credential $AzureCredential -TenantID $TenantID -Confirm:$false -ErrorAction Stop
        }
        else{
            $null = Connect-AzureAD -Credential $AzureCredential -Confirm:$false -ErrorAction Stop
        }
    }
    catch{
        throw
    }
}
function ConnectMSTeams(){
    <#
        .SYNOPSIS
            Open a connection to Microsoft Teams

        .DESCRIPTION

        .NOTES
            This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
            The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
            The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
            the use and the consequences of the use of this freely available script.
            PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
            © ScriptRunner Software GmbH

        .COMPONENT
            Requires Module microsoftteams

        .Parameter MTCredential
            Credential object containing the Microsoft Teams user/password

        .Parameter TenantID
            Specifies the ID of a tenant

        .Parameter LogLevel
            Specifies the log level
        #>

        [CmdLetBinding()]
        Param(
            [Parameter(Mandatory = $true)]  
            [PSCredential]$MTCredential,
            [string]$TenantId,
            [ValidateSet('Info','Error','Warning','None')]
            [string]$LogLevel = 'Info'
        )

        try{
            [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                        'Confirm' = $false
                        'LogLevel' = $LogLevel
                        'Credential' = $MTCredential
                        }
            if([System.String]::IsNullOrWhiteSpace($TenantId) -eq $false){
                $cmdArgs.Add('TenantId', $TenantId)
            }
            $null = Connect-MicrosoftTeams @cmdArgs                        
        }
        catch{
            throw
        }
        finally{
        }
}
function ConnectExchange(){
    <#
        .SYNOPSIS
            Connects the domain    

        .COMPONENT

        .Parameter ServerName
            FQDN of the Exchange server

        .Parameter ExchangeCredential
            Credential with sufficient permissions on Microsoft Exchange Server 

        .Parameter Session
            Returns session object
    #>

    param(
        [string]$ServerName,
        [pscredential]$ExchangeCredential,
        [ref]$Session
    )

    try{
        $uri = 'http://' + $ServerName + '/powershell/'
        $Session = New-PSSession  -ConfigurationName Microsoft.Exchange -Connectionuri $uri -credential $ExchangeCredential  
        if($null -ne $Session){
            $null = Import-PSSession $Session.Value -AllowClobber
        }
    }
    catch{
        throw
    }
}
function DisconnectExchange(){
    <#
        .SYNOPSIS
            Disconnects the Exchange session    

        .COMPONENT  

        .Parameter Session
            Session object
    #>

    param(
        $Session
    )

    try{        
        if($null -ne $Session){
            $null = Remove-PSSession $Session
        }
    }
    catch{
        throw
    }
}
function DisconnectAzureAD {
    <#
        .SYNOPSIS
            Disconnects the current session from an Azure Active Directory tenant

        .COMPONENT
            Requires Module AzureAD  
    #>
    
    param (        
    )    
    
    try{
        $null = Disconnect-AzureAD -Confirm:$false
    }
    catch{
        throw
    }
}
function DisconnectMSTeams(){
    <#
        .SYNOPSIS
            Closes the connection to Microsoft Teams

        .DESCRIPTION

        .NOTES
            This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
            The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
            The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
            the use and the consequences of the use of this freely available script.
            PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
            © ScriptRunner Software GmbH

        .COMPONENT
            Requires Module microsoftteams
        #>

        [CmdLetBinding()]
        Param(
        )

        try{
            Disconnect-MicrosoftTeams -Confirm:$false
        }
        catch{
            throw
        }
        finally{
        }
}
function AddUserToADGroups {
    <#
        .SYNOPSIS
            Add user to groups   

        .COMPONENT
            Requires Module ActiveDirectory

        .Parameter UserName
            SAMAccountName or DistinguishedName of Active Directory user
        
        .Parameter Groups
            Name of the groups to which the users added

        .Parameter ADCredential
            Active Directory Credential for remote execution without CredSSP        

        .Parameter DomainName
            Name of Active Directory Domain

        .Parameter AuthType
            Specifies the authentication method to use
    #>
    param (
        [Parameter(Mandatory = $true)]
        [string]$UserName,        
        [Parameter(Mandatory = $true)]
        [string[]]$Groups,
        [string]$DomainName,
        [PSCredential]$ADCredential,
        [ValidateSet('Basic', 'Negotiate')]
        [string]$AuthType = "Negotiate" 
    )

    try{
        # connect domain
        $domain = $null
        ConnectDomain -AuthType $AuthType -DomainName $DomainName -DomainAccount $ADCredential -Domain ([ref]$domain) 
        
        [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                                'Server' = $domain.PDCEmulator
                                'AuthType' = $AuthType
                                'Identity' =  $UserName
                                }

        if($null -ne $ADCredential){
            $cmdArgs.Add("Credential", $ADCredential)
        }
        $exists = Get-ADPrincipalGroupMembership @cmdArgs | Select-Object Name  
        foreach($item in $Groups){
            $tmp = $exists | Where-Object {$_.name -like $item}
            if($null -ne $tmp){
                continue
            }
            $null = Add-ADPrincipalGroupMembership @cmdArgs -MemberOf $item
            Write-Output "User $($UserName) added to group $($item)"
        }
    }
    catch{
        throw
    }
}
function CopyADMemberships {
    <#
        .SYNOPSIS
            Add users to the groups of source users    

        .COMPONENT
            Requires Module ActiveDirectory

        .Parameter SourceUsername
            SAMAccountName or DistinguishedName of Active Directory user
        
        .Parameter TargetUserName
            Specifies the new user's SAMAccountName or DistinguishedName      

        .Parameter ADCredential
            Active Directory Credential for remote execution without CredSSP        

        .Parameter DomainName
            Name of Active Directory Domain

        .Parameter AuthType
            Specifies the authentication method to use
    #>
    param (
        [Parameter(Mandatory = $true)]
        [string]$SourceUserName,        
        [Parameter(Mandatory = $true)]
        [string]$TargetUserName,
        [string]$DomainName,
        [PSCredential]$ADCredential,
        [ValidateSet('Basic', 'Negotiate')]
        [string]$AuthType = "Negotiate" 
    )

    try{    
        # connect domain
        $domain = $null
        ConnectDomain -AuthType $AuthType -DomainName $DomainName -DomainAccount $ADCredential -Domain ([ref]$domain)
        
        [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                                'Server' = $domain.PDCEmulator
                                'AuthType' = $AuthType
                                'Identity' =  $TargetUserName
                                }
        if($null -ne $ADCredential){
            $cmdArgs.Add("Credential", $ADCredential)
        }
        
        [int]$count = 0
        do{ # replication time
            try{
                $exists = Get-ADPrincipalGroupMembership @cmdArgs
            }
            catch{
            }
            if($null -eq $exists){
                Start-Sleep -Seconds 1
                $count ++
            }
            else{
                continue
            }
            
        } until ($count -lt 60)
        # get source memberships
        $cmdArgs.Item("Identity") =  $SourceUserName            
        $groups = Get-ADPrincipalGroupMembership @cmdArgs |  Where-Object SID -ne $exists.SID # remove domain users
        # set memberships to target user
        $cmdArgs.Item("Identity") =  $TargetUserName
        if(($null -ne $groups) -and ($groups.Length -gt 0)){
            $null = Add-ADPrincipalGroupMembership @cmdArgs -MemberOf $groups
            Write-Output "User $($TargetUserName) added to groups"
        }
    }
    catch{
        throw
    }
}
function CreateUserInAD {
    <#
        .SYNOPSIS
            Creates a user in the Active Directory
        
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

        .LINK
            https://github.com/scriptrunner/ActionPacks/tree/master/Automation%20Booster/_LIB_

        .Parameter OUPath
            Specifies the AD path

        .Parameter User
            Reference parameter for result

        .Parameter GivenName
            Specifies the user's given name

        .Parameter Surname
            Specifies the user's last name or surname

        .Parameter Password
            Specifies a new password value for an account

        .Parameter ADCredential
            Active Directory Credential for remote execution without CredSSP

        .Parameter SAMAccountName
            Specifies the Security Account Manager (SAM) account name of the user

        .Parameter UserPrincipalname
            Specifies the user principal name (UPN) in the format <user>@<DNS-domain-name>
            
        .Parameter UserName
            Specifies the name of the new user

        .Parameter DisplayName
            Specifies the display name of the user
        
        .Parameter Description
            Specifies a description of the user

        .Parameter EmailAddress
            Specifies the user's e-mail address

        .Parameter ChangePasswordAtLogon
            Specifies whether a password must be changed during the next logon attempt

        .Parameter CannotChangePassword
            Specifies whether the account password can be changed

        .Parameter PasswordNeverExpires
            Specifies whether the password of an account can expire

        .Parameter Department
            Specifies the user's department

        .Parameter Company
            Specifies the user's company

        .Parameter PostalCode
            Specifies the user's postal code or zip code

        .Parameter City
            Specifies the user's town or city

        .Parameter Street
            Specifies the user's street address

        .Parameter DomainName
            Name of Active Directory Domain
        
        .Parameter AuthType
            Specifies the authentication method to use
    #>
    param (
        [Parameter(Mandatory = $true)]
        [string]$GivenName,
        [Parameter(Mandatory = $true)]
        [string]$Surname,
        [Parameter(Mandatory = $true)]
        [securestring]$Password,  
        [Parameter(Mandatory = $true)]
        [ref]$User,  
        [string]$OUPath,   
        [switch]$ChangePasswordAtLogon,  
        [switch]$CannotChangePassword,
        [switch]$PasswordNeverExpires,
        [string]$SAMAccountName,
        [string]$UserPrincipalname,
        [string]$Username,
        [string]$DisplayName,
        [string]$Description,
        [string]$EmailAddress,
        [string]$Department,
        [string]$Company,
        [string]$PostalCode,
        [string]$City,   
        [string]$Street,
        [pscredential]$ADCredential,
        [string]$DomainName,
        [ValidateSet('Basic', 'Negotiate')]
        [string]$AuthType = "Negotiate"
    )

    try{
        if([System.String]::IsNullOrWhiteSpace($SAMAccountName) -eq $true){
            $SAMAccountName = $GivenName + '.' + $Surname 
        }
        if($SAMAccountName.Length -gt 20){
            $SAMAccountName = $SAMAccountName.Substring(0,20)
        }
        if([System.String]::IsNullOrWhiteSpace($Username) -eq $true){
            $Username = $GivenName + '_' + $Surname 
        }
        if([System.String]::IsNullOrWhiteSpace($DisplayName) -eq $true){
            $DisplayName = $GivenName + ', ' + $Surname 
        }
        # connect domain
        $domain = $null
        ConnectDomain -AuthType $AuthType -DomainName $DomainName -DomainAccount $ADCredential -Domain ([ref]$domain) 
        
        if([System.String]::IsNullOrWhiteSpace($UserPrincipalName) -eq $true){
            $UserPrincipalName = "$($GivenName).$($Surname)@$($domain.DNSRoot)"
        }
        elseif($UserPrincipalName.StartsWith('@')){
            $UserPrincipalName = $GivenName + '.' + $Surname + $UserPrincipalName
        }
        if([System.String]::IsNullOrWhiteSpace($EmailAddress) -eq $true){
            $EmailAddress = "$($GivenName).$($Surname)@$($domain.DNSRoot)"
        }
        elseif($EmailAddress.StartsWith('@')){
            $EmailAddress = $GivenName + '.' + $Surname + $EmailAddress
        }
        [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                    'Server' = $domain.PDCEmulator
                    'AuthType' = $AuthType
                    'Name' = $UserName 
                    'UserPrincipalName' = $UserPrincipalName 
                    'DisplayName' = $DisplayName 
                    'GivenName' = $GivenName 
                    'Surname' = $Surname 
                    'EmailAddress' = $EmailAddress
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
            if($null -ne $ADCredential){
                $cmdArgs.Add("Credential", $ADCredential)
            }
            if([System.String]::IsNullOrWhiteSpace($OUPath) -eq $false){
                $cmdArgs.Add("Path", $OUPath)
            }
            $null = New-ADUser @cmdArgs
            [int]$count = 0
            do{ # replication time
                $tmp = Get-ADUser -Identity $SAMAccountName -AuthType $AuthType -Server $domain.PDCEmulator -Properties *
                if($null -ne $tmp){
                    $User.Value = $tmp                    
                    Write-Output "User $($GivenName) $($SurName) created"
                    break
                }
                Start-Sleep -Seconds 1
                $count ++
            } until ($count -lt 60)
    }
    catch{
        throw
    }
}
function DeleteUserInAD {
    <#
        .SYNOPSIS
            Disbales, moves or removes a user in the Active Directory 

        .COMPONENT
            Requires Module ActiveDirectory

        .Parameter User
            SAMAccountName or DistinguishedName of Active Directory user
        
        .Parameter Delete
            Is the value 1, the user is deleted
        
        .Parameter Disable
            Is the value 1, the user is disabled
        
        .Parameter MoveToOU
            Moves the user to this OU

        .Parameter ADCredential
            Active Directory Credential for remote execution without CredSSP        

        .Parameter DomainName
            Name of Active Directory Domain

        .Parameter AuthType
            Specifies the authentication method to use
    #>
    param (
        [Parameter(Mandatory = $true)]
        [string]$User,
        [string]$Delete,
        [string]$Disable,
        [string]$MoveToOU,
        [string]$DomainName,
        [PSCredential]$ADCredential,
        [ValidateSet('Basic', 'Negotiate')]
        [string]$AuthType = "Negotiate" 
    )

    try{
        # connect domain
        $domain = $null
        ConnectDomain -AuthType $AuthType -DomainName $DomainName -DomainAccount $ADCredential -Domain ([ref]$domain) 
        
        [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                                'Server' = $domain.PDCEmulator
                                'AuthType' = $AuthType
                                'Identity' =  $User
                                'Confirm' = $false
                                }
        if($null -ne $ADCredential){
            $cmdArgs.Add("Credential", $ADCredential)
        }

        if($Delete -eq '1'){
            $null = Remove-ADUser @cmdArgs
            Write-Output "User $($User) removed"
            return
        } 
        if($Disable -eq '1'){
            $null = Disable-ADAccount @cmdArgs
            Write-Output "User $($User) disabled"
        }     
        if([System.String]::IsNullOrWhiteSpace($MoveToOU) -eq $false){
            $usr = Get-AdUser -Identity $User -Server $domain.PDCEmulator -AuthType $AuthType -ErrorAction Stop
            $cmdArgs.Item("Identity") = $usr.DistinguishedName
            $null = Move-ADObject @cmdArgs -TargetPath $MoveToOU
            Write-Output "User $($User) moved to $($MoveToOU)"
        }                            
    }
    catch{
        throw
    }
}
function AddO365UserToTeams{
    <#
        .SYNOPSIS
            Add user as member to MS Teams

        .COMPONENT
            Requires Module microsoftteams

        .Parameter TeamsCredential
            The Credential provides the user ID and password for organizational ID credentials
    
        .Parameter Teams
            Names of the teams

        .Parameter UserName
            User's UPN (user principal name)

        .Parameter TeamsTenant
            Specifies the ID of a tenant
    #>

    param(
        [Parameter(Mandatory = $true)]
        [pscredential]$TeamsCredential,
        [Parameter(Mandatory = $true)]
        [string]$UserName,
        [Parameter(Mandatory = $true)]
        [string[]]$Teams ,
        [string]$TeamsTenant
    )

    try{
        ConnectMSTeams -MTCredential $TeamsCredential -TenantId $TeamsTenant
        [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                                'User' = $UserName
                                'Role' = 'Member'
                                }      
        foreach($grp in $Teams){
            $team = Get-Team -DisplayName $grp -Erroraction Stop
            $null = Add-TeamUser @cmdArgs -GroupId $team.GroupId
            Write-Output "User $($UserName) added to team $($grp)"
        }
    }
    catch{
        throw
    }
    finally{
        DisconnectMSTeams
    }
}
function AddO365LicensesToUser{
    <#
        .SYNOPSIS
            Assign licenes to MS user

        .COMPONENT
            Requires Module microsoftteams

        .Parameter O365Credential
            The Credential provides the user ID and password for organizational ID credentials
    
        .Parameter Licenses
            List of license SkuIDs

        .Parameter UserName
            User's UPN (user principal name)

        .Parameter Tenant
            Specifies the ID of a tenant
    #>

    param(
        [Parameter(Mandatory = $true)]
        [pscredential]$O365Credential,
        [Parameter(Mandatory = $true)]
        [string]$UserName,
        [Parameter(Mandatory = $true)]
        [string[]]$Licenses,
        [string]$Tenant
    )

    try{
        ConnectAzureAD -AzureCredential $O365Credential -TenantID $Tenant
        $loc = Get-AzureADUser -ObjectId $UserName | Select-Object UsageLocation
        if([System.String]::IsNullOrWhiteSpace($loc.UsageLocation) -eq $true){
            # usage location must set before licenses assign
            $loc = Get-AzureADUser -ObjectId $O365Credential.UserName | Select-Object UsageLocation
            Set-AzureADUser -ObjectId $UserName -UsageLocation $loc.UsageLocation
        }
        $licList = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicenses
        $licList.AddLicenses = New-Object 'System.Collections.Generic.List[Microsoft.Open.AzureAD.Model.AssignedLicense]'
                            
        foreach($lic in $Licenses){
            $license = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicense
            $license.SkuId = $lic
            $licList.AddLicenses.Add($license)
        }
        $null = Set-AzureADUserLicense -ObjectId $UserName -AssignedLicenses $licList -ErrorAction Stop        
    }
    catch{
        throw
    }
    finally{
        DisconnectAzureAD 
    }
}
function CreateUserInO365{
<#
    .SYNOPSIS
        Connect to Azure Active Directory and creates a user    

    .COMPONENT
        Requires Module AzureAD (Azure Active Directory Powershell Module v2)
            Requires Module microsoftteams for add Teams memberships

    .Parameter O365Credential
        The Credential provides the user ID and password for organizational ID credentials

    .Parameter Tenant
        Specifies the ID of a tenant

    .Parameter User
        Reference parameter for result

    .Parameter UserPrincipalName
        Specifies the user ID for this user

    .Parameter Password
        Specifies the new password for the user

    .Parameter DisplayName
        Specifies the display name of the user

    .Parameter Enabled
        Specifies whether the user is able to log on using their user ID

    .Parameter FirstName
        Specifies the first name of the user

    .Parameter LastName
        Specifies the last name of the user

    .Parameter MailNickName
        Specifies the user's mail nickname

    .Parameter PostalCode
        Specifies the postal code of the user

    .Parameter City
        Specifies the city of the user

    .Parameter Street
        Specifies the street address of the user

    .Parameter PhoneNumber
        Specifies the phone number of the user

    .Parameter MobilePhone
        Specifies the mobile phone number of the user

    .Parameter Department
        Specifies the department of the user

    .Parameter ForceChangePasswordNextLogin
        Forces a user to change their password during their next log iny

    .Parameter ShowInAddressList 
        Specifies show this user in the address list

    .Parameter UserType 
        Specifies the type of the user in your directory
    #>

    param (
        [Parameter(Mandatory = $true)]
        [pscredential]$O365Credential, 
        [Parameter(Mandatory = $true)]
        [ref]$User,  
        [Parameter(Mandatory = $true)]
        [string]$UserPrincipalName,
        [Parameter(Mandatory = $true)]
        [securestring]$Password,
        [Parameter(Mandatory = $true)]
        [string]$DisplayName,
        [bool]$Enabled = $true,
        [string]$FirstName,
        [string]$LastName,
        [string]$MailNickName,
        [string]$PostalCode,
        [string]$City,
        [string]$Street,
        [string]$PhoneNumber,
        [string]$MobilePhone,
        [string]$Department,
        [bool]$ForceChangePasswordNextLogin,
        [bool]$ShowInAddressList,
        [ValidateSet('Member','Guest')]
        [string]$UserType = 'Member',
        [string]$Tenant
    )

    try{
        ConnectAzureAD -AzureCredential $O365Credential -TenantID $Tenant
        $PasswordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
        $PasswordProfile.Password = $Password
        $PasswordProfile.ForceChangePasswordNextLogin =$ForceChangePasswordNextLogin
        if([System.String]::IsNullOrWhiteSpace($MailNickName) -eq $true){
            $MailNickName = $UserPrincipalName.Substring(0, $UserPrincipalName.IndexOf('@'))
        }   
        [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                                'UserPrincipalName' = $UserPrincipalName
                                'DisplayName' = $DisplayName
                                'AccountEnabled' = $Enabled
                                'MailNickName' = $MailNickName
                                'UserType' = $UserType
                                'PasswordProfile' = $PasswordProfile
                                'ShowInAddressList' = $ShowInAddressList
                                } 
                                
        if([System.String]::IsNullOrWhiteSpace($FirstName) -eq $false ){
            $cmdArgs.Add('GivenName', $FirstName)
        }
        if([System.String]::IsNullOrWhiteSpace($LastName) -eq $false ){
            $cmdArgs.Add('Surname', $LastName)
        }
        if([System.String]::IsNullOrWhiteSpace($PostalCode) -eq $false ){
            $cmdArgs.Add('PostalCode', $PostalCode)
        }
        if([System.String]::IsNullOrWhiteSpace($City) -eq $false ){
            $cmdArgs.Add('City', $City)
        }
        if([System.String]::IsNullOrWhiteSpace($Street) -eq $false ){
            $cmdArgs.Add('StreetAddress', $Street)
        }
        if([System.String]::IsNullOrWhiteSpace($PhoneNumber) -eq $false ){
            $cmdArgs.Add('TelephoneNumber', $PhoneNumber)
        }
        if([System.String]::IsNullOrWhiteSpace($MobilePhone) -eq $false ){
            $cmdArgs.Add('Mobile', $MobilePhone)
        }
        if([System.String]::IsNullOrWhiteSpace($Department) -eq $false ){
            $cmdArgs.Add('Department', $Department)
        }
        $User = New-AzureADUser @cmdArgs | Select-Object *
        
        Write-Output "O365 User $($MailNickName) created"
    }
    catch{
        throw
    }
    finally{
        DisconnectAzureAD 
    }
}
function DeleteUserInO365 {
    <#
        .SYNOPSIS
            Disbales or removes a user in the Azure Active Directory

        .COMPONENT
            Requires Module AzureAD (Azure Active Directory Powershell Module v2)
            Requires Module microsoftteams for remove Teams memberships

        .Parameter O365Credential
            The Credential provides the user ID and password for organizational ID credentials

        .Parameter Tenant
            Specifies the ID of a tenant

        .Parameter UserName           
            Specifies the UserPrincipalName for this user
        
        .Parameter Delete
            Is the value 1, the user is deleted
        
        .Parameter Disable
            Is the value 1, the user is disabled

        .Parameter HideInAddressLists
            Is the value 1, the user hides in the address lists
    #>
    param (
        [Parameter(Mandatory = $true)]
        [pscredential]$O365Credential, 
        [Parameter(Mandatory = $true)]
        [string]$UserName,
        [string]$Delete,
        [string]$Disable,
        [string]$HideInAddressLists,
        [string]$Tenant
    )

    try{
        # connect domain
        ConnectAzureAD -AzureCredential $O365Credential -TenantID $Tenant
        
        [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                                'ObjectId' =  $UserName
                                }            
        
        if($HideInAddressLists -eq '1'){
            $null = Set-AzureADUser @cmdArgs -ShowInAddressList $false
            Write-Output "O365 User $($UserName) hides in address lists"
        } 
        if($Disable -eq '1'){
            $null = Set-AzureADUser @cmdArgs -AccountEnabled $false
            Write-Output "O365 User $($UserName) disabled"
        }       
        if($Delete -eq '1'){
            $null = Remove-AzureADUser @cmdArgs
            Write-Output "O365 User $($UserName) removed"
        }    
    }
    catch{
        throw
    }
    finally{
        DisconnectAzureAD 
    }
}
function RemoveO365UserFromTeams(){
    <#
        .SYNOPSIS
            Removes user from MS Teams

        .COMPONENT
            Requires Module microsoftteams

        .Parameter TeamsCredential
            The Credential provides the user ID and password for organizational ID credentials
    
        .Parameter UserName
            User's UPN (user principal name)

        .Parameter TeamsTenant
            Specifies the ID of a tenant
    #>

    param(
        [Parameter(Mandatory = $true)]
        [pscredential]$TeamsCredential,
        [Parameter(Mandatory = $true)]
        [string]$UserName,
        [string]$TeamsTenant
    )

    ConnectMSTeams -MTCredential $TeamsCredential -TenantId $TeamsTenant
    try{
        $teams = Get-Team -User $UserName -ErrorAction Stop
        foreach($itm in $teams){
            $null = Remove-TeamUser -GroupID $itm.GroupID -User $UserName -ErrorAction Stop
            Write-Output "O365 User $($UserName) removed from Team $($itm.DisplayName)"        
        }
    }
    catch{
        throw
    }
    finally{
        DisconnectMSTeams 
    }
    
}
function ExchangeSetActiveSync(){
    <#
        .SYNOPSIS
            De-/Activates ActiveSync

        .COMPONENT

        .Parameter UserName
            Specifies the logon name for the user account

        .Parameter Enable
            Enables ActiveSync
    #>

    param(
        [Parameter(Mandatory = $true)]
        [string]$UserName,        
        [Parameter(Mandatory = $true)]
        [bool]$Enable
    )

    try{
        $null = Set-CASMailbox -Identity $UserName -ActiveSyncEnabled $Enable -ErrorAction Stop
        if($Enable){
            Write-Output "Exchange Mailbox $($UserName) ActiveSync enabled"
        }
        else{
            Write-Output "Exchange Mailbox $($UserName) ActiveSync disabled"
        }
    }
    catch{
        throw
    }

}
function CreateExchangeMailbox(){
    <#
        .SYNOPSIS
            Connect to Microsoft Exchange Server and create the mailbox

        .COMPONENT

        .Parameter ExCredential
            Credential with sufficient permissions on Microsoft Exchange Server
    
        .Parameter UserName
            Specifies the logon name for the user account

        .Parameter ActivateActiveSync
            Enable ActiveSync for the mailbox

        .Parameter ServerName
            Specifies the Fully Qualified Domain Name of the Microsoft Exchange Server 
            
        .Parameter Mailbox
            Result object
    #>

    param(
        [Parameter(Mandatory = $true)]            
        [string]$UserName,
        [Parameter(Mandatory = $true)]
        [string]$ServerName,
        [Parameter(Mandatory = $true)]
        [PSCredential]$ExCredential,
        [bool]$ActivateActiveSync,
        [Parameter(Mandatory = $true)]
        [ref]$Mailbox
    )

    $session = $null
    try{
        ConnectExchange -ServerName $ServerName -ExchangeCredential $ExCredential -Session ([ref]$session)
        $null = Enable-Mailbox -Identity $UserName -Force -Confirm:$false -ErrorAction Stop
        Write-Output "Exchange Mailbox $($UserName) enabled" 
        ExchangeSetActiveSync -UserName $UserName -Enable $ActivateActiveSync
        $Mailbox = Get-Mailbox -Identity $UserName -ErrorAction Stop | Select-Object *
    }
    catch{
        throw
    }
    finally{
        DisconnectExchange -Session $session
    }
}
function ForwardExchangeMailbox(){
    <#
        .SYNOPSIS
            Inbox rule that forwards the messages to the specified recipient

        .COMPONENT

        .Parameter MailboxId
            Specifies the uniquely identifies of the mailbox

        .Parameter Recipient
            Specifies the uniquely identifies of the recipient
    #>
   
    param(
        [Parameter(Mandatory = $true)]
        [string]$MailboxId,
        [Parameter(Mandatory = $true)]
        [string]$Recipient
    )
   
    try{   
        $box = Get-Mailbox -Identity $Recipient | Select-Object *
        $null = Set-Mailbox -Identity $MailboxId -ForwardingAddress $box.PrimarySmtpAddress -Force -DeliverToMailboxAndForward $false -ErrorAction Stop           
        Write-Output "Mailbox $($MailboxId) forward to $($Recipient)"
    }
    catch{
        throw
    }
    finally{    
    }
}
function OffBoardExchangeMailbox(){
    <#
        .SYNOPSIS
            Connect to Microsoft Exchange Server and disables, removes the mailbox

        .COMPONENT

        .Parameter ExCredential
            Credential with sufficient permissions on Microsoft Exchange Server
    
        .Parameter UserName
            Specifies the logon name for the user account
        
        .Parameter Delete
            Is the value 1, the mailbox is deleted
        
        .Parameter DeletePermanent
            Is the value 1, the mailbox is deleted permanent
        
        .Parameter Disable
            Is the value 1, the mailbox is disabled
        
        .Parameter ForwardTo
            Specifies the recipient to forward the message to

        .Parameter ServerName
            Specifies the Fully Qualified Domain Name of the Microsoft Exchange Server 
    #>

    param(
        [Parameter(Mandatory = $true)]            
        [string]$UserName,
        [Parameter(Mandatory = $true)]
        [string]$ServerName,
        [Parameter(Mandatory = $true)]
        [PSCredential]$ExCredential,
        [string]$Delete,
        [string]$DeletePermanent,
        [string]$Disable,
        [string]$ForwardTo
    )

    $session = $null
    try{
        ConnectExchange -ServerName $ServerName -ExchangeCredential $ExCredential -Session ([ref]$session)

        [bool]$perm = $false
        [string]$ext = ''
        if($DeletePermanent -eq '1'){
            $perm = $true
            $ext = 'permanent'
            $Delete = '1'
        }
        if([System.String]::IsNullOrWhiteSpace($ForwardTo) -eq $false){
            ForwardExchangeMailbox -MailboxId $UserName -Recipient $ForwardTo
        }
        if($Delete -eq '1'){
            $null = Remove-Mailbox -Identity $UserName -Permanent $perm -Confirm:$false -Force -ErrorAction Stop
            Write-Output "Exchange Mailbox $($UserName) removed $($ext)" 
        }
        elseif($Disable -eq '1'){
            $null = Disable-Mailbox -Identity $UserName -Confirm:$false -ErrorAction Stop
            Write-Output "Exchange Mailbox $($UserName) disabled"
        }
    }
    catch{
        throw
    }
    finally{
        DisconnectExchange -Session $session
    }
}
function AddUserToExchangeDistributionGroups(){
    <#
        .SYNOPSIS
            Adds user to Distribution groups

        .COMPONENT

        .Parameter ExCredential
            Credential with sufficient permissions on Microsoft Exchange Server

        .Parameter ServerName
            Specifies the Fully Qualified Domain Name of the Microsoft Exchange Server 

        .Parameter UserName
            Specifies the SamAccountName for the user

        .Parameter Groups
            Distribution groups
    #>

    param(
        [Parameter(Mandatory = $true)]
        [string]$ServerName,
        [Parameter(Mandatory = $true)]
        [PSCredential]$ExCredential,
        [Parameter(Mandatory = $true)]
        [string]$UserName,        
        [Parameter(Mandatory = $true)]
        [string[]]$Groups
    )

    $session = $null
    try{
        if(($null -eq $Groups) -or ($Groups.Length -le 0)){
            return
        }
        ConnectExchange -ServerName $ServerName -ExchangeCredential $ExCredential -Session ([ref]$session)
        foreach($grp in $Groups){
            try{
                $tmp = Get-DistributionGroupMember -Identity $grp | `
                        Where-Object {$_.SAMAccountName -eq $SAMAccountName}
                if($null -eq $tmp){
                    $null = Add-DistributionGroupMember -Identity $grp -Member $UserName -BypassSecurityGroupManagerCheck -Confirm:$false -ErrorAction Stop
                    Write-Output "User $($SAMAccountName) added to Exchange group $($grp)"
                }
                else{
                    Write-Output "User $($SAMAccountName) is already a member of the Exchange group $($grp)"
                }
            }
            catch{
                Write-Output "Error on add user $($SAMAccountName) to Exchange group $($grp) - $($_.Exception.Message)"
            }
        }
    }
    catch{
        throw
    }
    finally{    
        DisconnectExchange -Session $session    
    }
}
function RemoveUserFromExchangeDistributionGroups(){
    <#
        .SYNOPSIS
            Removes user to Distribution groups

        .COMPONENT

        .Parameter ExCredential
            Credential with sufficient permissions on Microsoft Exchange Server

        .Parameter ServerName
            Specifies the Fully Qualified Domain Name of the Microsoft Exchange Server 

        .Parameter UserName
            Specifies the SamAccountName for the user
    #>

    param(
        [Parameter(Mandatory = $true)]
        [string]$ServerName,
        [Parameter(Mandatory = $true)]
        [PSCredential]$ExCredential,
        [Parameter(Mandatory = $true)]
        [string]$UserName
    )

    $session = $null
    try{
        ConnectExchange -ServerName $ServerName -ExchangeCredential $ExCredential -Session ([ref]$session)        
        Get-DistributionGroup | ForEach-Object{
            try{
                $tmp = Get-DistributionGroupMember -Identity $_.Name | Where-Object {$_.SAMAccountName -eq $UserName}
                if($null -ne $tmp){
                    $null = Remove-DistributionGroupMember -Identity $_.Name -Member $UserName -BypassSecurityGroupManagerCheck -Confirm:$false -ErrorAction Stop
                    "User $($UserName) removed from the Exchange group $($_.DisplayName)"
                }
            }
            catch{
                Write-Output "Error on remove user $($UserName) from Exchange group - $($_.Exception.Message)"
            }
        }
    }
    catch{
        throw
    }
    finally{    
        DisconnectExchange -Session $session    
    }
}