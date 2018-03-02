#Requires -Version 4.0
#Requires -Modules ActiveDirectory

<#
    .SYNOPSIS
         Resets the password of the Active Directory account
    
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

    .Parameter NewPassword
        The new password for the Active Directory account

    .Parameter DomainAccount
        Active Directory Credential for remote execution without CredSSP

    .Parameter UserMustChangePasswordAtLogon
        The user must change the password on the next logon

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
    [string]$Username,
    [Parameter(Mandatory = $true,ParameterSetName = "Local or Remote DC")]
    [Parameter(Mandatory = $true,ParameterSetName = "Remote Jumphost")]
    [string]$NewPassword,
    [Parameter(Mandatory = $true,ParameterSetName = "Remote Jumphost")]
    [PSCredential]$DomainAccount,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [switch]$UserMustChangePasswordAtLogon,
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
    [string]$AuthType="Negotiate"
)

Import-Module ActiveDirectory

#Clear
#$ErrorActionPreference='Stop'
try{
    $Script:NPwd = ConvertTo-SecureString $NewPassword -AsPlainText -Force
    $Script:User 
    $Script:Domain
    $Script:Properties =@('GivenName','Surname','SAMAccountName','UserPrincipalname','Name','DisplayName','Description','EmailAddress', 'CannotChangePassword','PasswordNeverExpires' `
                            ,'Department','Company','PostalCode','City','StreetAddress','DistinguishedName')

    if($PSCmdlet.ParameterSetName  -eq "Remote Jumphost"){
        if([System.String]::IsNullOrWhiteSpace($DomainName)){
            $Script:Domain = Get-ADDomain -Current LocalComputer -AuthType $AuthType -Credential $DomainAccount -ErrorAction Stop
        }
        else{
            $Script:Domain = Get-ADDomain -Identity $DomainName -AuthType $AuthType -Credential $DomainAccount -ErrorAction Stop
        }
        $Script:User= Get-ADUser -Server $Script:Domain.PDCEmulator -Credential $DomainAccount -AuthType $AuthType `
            -SearchBase $OUPath -SearchScope $SearchScope `
            -Filter {(SamAccountName -eq $Username) -or (DisplayName -eq $Username) -or (DistinguishedName -eq $Username) -or (UserPrincipalName -eq $Username)}  -ErrorAction Stop
    }
    else{
        if([System.String]::IsNullOrWhiteSpace($DomainName)){
            $Script:Domain = Get-ADDomain -Current LocalComputer -AuthType $AuthType  -ErrorAction Stop
        }
        else{
            $Script:Domain = Get-ADDomain -Identity $DomainName -AuthType $AuthType  -ErrorAction Stop
        }
        $Script:User= Get-ADUser -Server $Script:Domain.PDCEmulator -AuthType $AuthType `
            -SearchBase $OUPath -SearchScope $SearchScope `
            -Filter {(SamAccountName -eq $Username) -or (DisplayName -eq $Username) -or (DistinguishedName -eq $Username) -or (UserPrincipalName -eq $Username)} -ErrorAction Stop
    }
    if($null -ne $Script:User){
        $Out=@()
        if($PSCmdlet.ParameterSetName  -eq "Remote Jumphost"){
            Set-ADAccountPassword -Identity $Script:User -Credential $DomainAccount -Server $Script:Domain.PDCEmulator -AuthType $AuthType -NewPassword $Script:NPwd -Reset -ErrorAction Stop
        }
        else {
            Set-ADAccountPassword -Identity $Script:User -Server $Script:Domain.PDCEmulator -AuthType $AuthType -NewPassword $Script:NPwd -Reset -ErrorAction Stop
        }
        $Out += "New password of user $($Username) is set"
        if($UserMustChangePasswordAtLogon -eq $true){
            if($PSCmdlet.ParameterSetName  -eq "Remote Jumphost"){
                Set-ADUser -PasswordNeverExpires $false -ChangePasswordAtLogon $true -CannotChangePassword $false -Credential $DomainAccount -Server $Script:Domain.PDCEmulator -AuthType $AuthType -Identity $Script:User -ErrorAction Stop
            }
            else {
                Set-ADUser -PasswordNeverExpires $false -ChangePasswordAtLogon $true -CannotChangePassword $false -Server $Script:Domain.PDCEmulator -AuthType $AuthType -Identity $Script:User -ErrorAction Stop
            }
            $Out +=  "User $($Username) must change the password on next logon"
        }
        Start-Sleep -Seconds 5 # wait
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
        $Out +=$res | Format-Table -HideTableHeaders
        if($SRXEnv) {
            $SRXEnv.ResultMessage =$Out
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