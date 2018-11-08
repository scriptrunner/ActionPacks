#Requires -Version 4.0
#Requires -Modules ActiveDirectory

<#
    .SYNOPSIS
        Sets the properties of the Active Directory user.
        Only parameters with value are set
    
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

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/ActiveDirectory/Users

    .Parameter OUPath
        Specifies the AD path

    .Parameter Username
        Display name, SAMAccountName, DistinguishedName or user principal name of Active Directory account

    .Parameter DomainAccount
        Active Directory Credential for remote execution without CredSSP

    .Parameter GivenName
        Specifies the user's given name

    .Parameter Surname
        Specifies the user's last name or surname

    .Parameter DisplayName
        Specifies the display name of the user

    .Parameter Description
        Specifies a description of the user

    .Parameter CannotChangePassword
        Specifies whether the account password can be changed

    .Parameter PasswordNeverExpires
        Specifies whether the password of an account can expire

    .Parameter Office
        Specifies the location of the user's office or place of business
    
    .Parameter EmailAddress
        Specifies the user's e-mail address

    .Parameter Phone
        Specifies the user's office telephone number

    .Parameter Title
        Specifies the user's title

    .Parameter Department
        Specifies the user's department

    .Parameter Company
        Specifies the user's company

    .Parameter Street
        Specifies the user's street address

    .Parameter PostalCode
        Specifies the user's postal code or zip code

    .Parameter City
        Specifies the user's town or city

    .Parameter DomainName
        Name of Active Directory Domain

    .Parameter SearchScope
        Specifies the scope of an Active Directory search

    .Parameter AuthType
        Specifies the authentication method to use
    
    .Parameter Simulate
        Indicates that the script is run only to display the changes that would be made and actually no objects are modified
#>

param(
    [Parameter(Mandatory = $true,ParameterSetName = "Local or Remote DC")]
    [Parameter(Mandatory = $true,ParameterSetName = "Remote Jumphost")]
    [string]$OUPath,   
    [Parameter(Mandatory = $true,ParameterSetName = "Local or Remote DC")]
    [Parameter(Mandatory = $true,ParameterSetName = "Remote Jumphost")]
    [string]$Username,
    [Parameter(Mandatory = $true,ParameterSetName = "Remote Jumphost")]
    [PSCredential]$DomainAccount,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [string]$GivenName,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [string]$Surname,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [string]$DisplayName,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [string]$Description,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [switch]$CannotChangePassword,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [switch]$PasswordNeverExpires,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [string]$Office,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [string]$EmailAddress,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [string]$Phone,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [string]$Title,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [string]$Department,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [string]$Company,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [string]$Street,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [string]$PostalCode,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [string]$City,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [string]$DomainName,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [ValidateSet('Base','OneLevel','SubTree')]
    [string]$SearchScope='SubTree',
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [ValidateSet('Basic', 'Negotiate')]
    [string]$AuthType="Negotiate",
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [switch]$Simulate
)

Import-Module ActiveDirectory

try{
    $Script:User 
    $Script:Domain
    $Script:Properties =@('GivenName','Surname','SAMAccountName','UserPrincipalname','Name','DisplayName','Description','EmailAddress', 'CannotChangePassword','PasswordNeverExpires' `
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

    $cmdArgs = @{'ErrorAction' = 'Stop'
                'Server' = $Domain.PDCEmulator
                'AuthType' = $AuthType
                'Filter' = {(SamAccountName -eq $Username) -or (DisplayName -eq $Username) -or (DistinguishedName -eq $Username) -or (UserPrincipalName -eq $Username)}
                'SearchBase' = $OUPath 
                'SearchScope' = $SearchScope
                }
    if($null -ne $DomainAccount){
        $cmdArgs.Add("Credential", $DomainAccount)
    }
    $Script:User= Get-ADUser @cmdArgs

    if($null -ne $Script:User){
        $cmdArgs = @{'ErrorAction' = 'Stop'
                    'Server' = $Domain.PDCEmulator
                    'AuthType' = $AuthType
                    'PassThru' = $null
                    'Confirm' = $false           
                    }
        if($null -ne $DomainAccount){
            $cmdArgs.Add("Credential", $DomainAccount)
        }
        
        if(-not [System.String]::IsNullOrWhiteSpace($GivenName)){
            $Script:User.GivenName = $GivenName
        }
        if(-not [System.String]::IsNullOrWhiteSpace($Surname)){
            $Script:User.Surname = $Surname
        }
        if(-not [System.String]::IsNullOrWhiteSpace($Description)){
            $Script:User.Description = $Description
        }
        if(-not [System.String]::IsNullOrWhiteSpace($DisplayName)){
            $Script:User.DisplayName = $DisplayName
        }
        if(-not [System.String]::IsNullOrWhiteSpace($Office)){
            $Script:User.Office = $Office
        }
        if(-not [System.String]::IsNullOrWhiteSpace($EmailAddress)){
            $Script:User.EmailAddress = $EmailAddress
        }
        if(-not [System.String]::IsNullOrWhiteSpace($Phone)){
            $Script:User.OfficePhone = $Phone
        }
        if(-not [System.String]::IsNullOrWhiteSpace($Title)){
            $Script:User.Title = $Title
        }
        if(-not [System.String]::IsNullOrWhiteSpace($Department)){
            $Script:User.Department = $Department
        }
        if(-not [System.String]::IsNullOrWhiteSpace($Company)){
            $Script:User.Company = $Company
        }
        if(-not [System.String]::IsNullOrWhiteSpace($Street)){
            $Script:User.StreetAddress = $Street
        }
        if(-not [System.String]::IsNullOrWhiteSpace($PostalCode)){
            $Script:User.PostalCode = $PostalCode
        }
        if(-not [System.String]::IsNullOrWhiteSpace($City)){
            $Script:User.City = $City
        }
        if($PSBoundParameters.ContainsKey('CannotChangePassword') -eq $true ){
            $Script:User.CannotChangePassword = $CannotChangePassword.ToBool()
        }
        if($PSBoundParameters.ContainsKey('PasswordNeverExpires') -eq $true){
            $Script:User.PasswordNeverExpires = $PasswordNeverExpires.ToBool()
        }
        $cmdArgs.Add('Instance',$Script:User)
        if(-not $Simulate){
            $Script:User = Set-ADUser @cmdArgs
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
        $Out +="User $($Username) changed"
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
            $SRXEnv.ResultMessage = "User $($Username) not found"
        }    
        Throw "User $($Username) not found"
    }   
}
catch{
    throw
}
finally{
}