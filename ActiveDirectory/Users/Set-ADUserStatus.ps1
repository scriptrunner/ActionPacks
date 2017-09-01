#Requires -Modules ActiveDirectory

<#
    .SYNOPSIS
         Enable, disable and/or unlock a Active Directory account
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, AppSphere AG assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of AppSphere AG.
        © AppSphere AG

    .Parameter OUPath
        Specifies the AD path

    .Parameter Username
        Display name, SAMAccountName, DistinguishedName or user principal name of Active Directory account

    .Parameter DomainAccount
        Active Directory Credential for remote execution without CredSSP

    .Parameter EnableStatus
        Enables or disables the Active Directory account
        
    .Parameter UnLock
        Unlock the Active Directory account

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
    [Parameter(Mandatory = $true,ParameterSetName = "Remote Jumphost")]
    [PSCredential]$DomainAccount,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [ValidateSet('Enable','Disable')]
    [string]$EnableStatus='Enable',
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [switch]$UnLock,
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

$Script:Domain 
$Script:User 
$Script:Properties =@('GivenName','Surname','SAMAccountName','UserPrincipalname','Name','DisplayName','Description','EmailAddress', 'CannotChangePassword','PasswordNeverExpires' `
                        ,'Department','Company','PostalCode','City','StreetAddress','Enabled','DistinguishedName')

if($PSCmdlet.ParameterSetName  -eq "Remote Jumphost"){
    if([System.String]::IsNullOrWhiteSpace($DomainName)){
        $Script:Domain = Get-ADDomain -Current LocalComputer -AuthType $AuthType -Credential $DomainAccount
    }
    else{
        $Script:Domain = Get-ADDomain -Identity $DomainName -AuthType $AuthType -Credential $DomainAccount
    }
    $Script:User= Get-ADUser -Server $Script:Domain.PDCEmulator -Credential $DomainAccount -AuthType $AuthType -Properties LockedOut,Enabled `
        -SearchBase $OUPath -SearchScope $SearchScope `
        -Filter {(SamAccountName -eq $Username) -or (DisplayName -eq $Username) -or (DistinguishedName -eq $Username) -or (UserPrincipalName -eq $Username)}
}
else{
    if([System.String]::IsNullOrWhiteSpace($DomainName)){
        $Script:Domain = Get-ADDomain -Current LocalComputer -AuthType $AuthType 
    }
    else{
        $Script:Domain = Get-ADDomain -Identity $DomainName -AuthType $AuthType 
    }
    $Script:User= Get-ADUser -Server $Script:Domain.PDCEmulator -AuthType $AuthType -Properties LockedOut,Enabled `
        -SearchBase $OUPath -SearchScope $SearchScope `
        -Filter {(SamAccountName -eq $Username) -or (DisplayName -eq $Username) -or (DistinguishedName -eq $Username) -or (UserPrincipalName -eq $Username)}
}
if($null -ne $Script:User){
    $Out=@()
    if($UnLock -eq $true){
        if($Script:User.LockedOut -eq $true){
            if($PSCmdlet.ParameterSetName  -eq "Remote Jumphost"){
                Unlock-ADAccount -Identity $Script:User -Credential $DomainAccount -AuthType $AuthType -Server $Script:Domain.PDCEmulator
            }
            else {
                Unlock-ADAccount -Identity $Script:User -AuthType $AuthType -Server $Script:Domain.PDCEmulator
            }
            $Out += "User $($Username) unlocked"
        }
        else{
            $Out += "User $($Username) is not locked"
        }
    }
    if($EnableStatus -eq 'Enable'){
        if($Script:User.Enabled -eq $false){
            if($PSCmdlet.ParameterSetName  -eq "Remote Jumphost"){
                Enable-ADAccount -Identity $Script:User -Credential $DomainAccount -AuthType $AuthType -Server $Script:Domain.PDCEmulator
            }
            else {
                Enable-ADAccount -Identity $Script:User -AuthType $AuthType -Server $Script:Domain.PDCEmulator
            }
            $Out += "User $($Username) enabled"
        }
        else{
            $Out += "User $($Username) is not disabled"
        }
    }
    else{
        if($Script:User.Enabled -eq $true){
            if($PSCmdlet.ParameterSetName  -eq "Remote Jumphost"){
                Disable-ADAccount -Identity $Script:User -Credential $DomainAccount -Server $Script:Domain.PDCEmulator -AuthType $AuthType
            }
            else {
                Disable-ADAccount -Identity $Script:User -Server $Script:Domain.PDCEmulator -AuthType $AuthType
            }
            $Out += "User $($Username) disabled"
        }
        else{
            $Out += "User $($Username) is not enabled"
        }
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