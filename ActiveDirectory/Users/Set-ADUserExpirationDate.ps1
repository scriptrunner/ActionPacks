#Requires -Modules ActiveDirectory

<#
    .SYNOPSIS
         Sets the expiration date for an Active Directory account
    
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

    .Parameter Day
        Specifies the day of the expiration date for an the Active Directory account

    .Parameter Month
        Specifies the day of the expiration date for an the Active Directory account

    .Parameter Year
        Specifies the day of the expiration date for an the Active Directory account
        
    .Parameter NeverExpires
        Specifies the Active Directory account never expires        

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
    [ValidateRange(1,31)]
    [int]$Day=1,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [ValidateRange(1,12)]
    [int]$Month=1,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [ValidateRange(2017,2030)]
    [int]$Year,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [switch]$NeverExpires,
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

if($PSCmdlet.ParameterSetName  -eq "Remote Jumphost"){
    if([System.String]::IsNullOrWhiteSpace($DomainName)){
        $Script:Domain = Get-ADDomain -Current LocalComputer -AuthType $AuthType -Credential $DomainAccount
    }
    else{
        $Script:Domain = Get-ADDomain -Identity $DomainName -AuthType $AuthType -Credential $DomainAccount
    }
    $Script:User= Get-ADUser -Server $Script:Domain.PDCEmulator -Credential $DomainAccount -AuthType $AuthType `
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
    $Script:User= Get-ADUser -Server $Script:Domain.PDCEmulator -AuthType $AuthType `
        -SearchBase $OUPath -SearchScope $SearchScope `
        -Filter {(SamAccountName -eq $Username) -or (DisplayName -eq $Username) -or (DistinguishedName -eq $Username) -or (UserPrincipalName -eq $Username)}
}
if($null -ne $Script:User){
    $Out=''
    if($NeverExpires -eq $true){
        if($PSCmdlet.ParameterSetName  -eq "Remote Jumphost"){
            Set-ADUser -Identity $Script:User.SamAccountName -Credential $DomainAccount -AuthType $AuthType -Server $Script:Domain.PDCEmulator -AccountExpirationDate $null
        }
        else {
            Set-ADUser -Identity $Script:User.SamAccountName -AuthType $AuthType -Server $Script:Domain.PDCEmulator -AccountExpirationDate $null
        }
    }
    else{
        [datetime]$start = New-Object DateTime $Year, $Month, $Day
        if($start.ToFileTimeUtc() -lt [DateTime]::Now.ToFileTimeUtc()){
            Throw "Expiration date is in the past"
        }
        if($PSCmdlet.ParameterSetName  -eq "Remote Jumphost"){
            Set-ADUser -Identity $Script:User.SamAccountName -Credential $DomainAccount -AuthType $AuthType -Server $Script:Domain.PDCEmulator -AccountExpirationDate $start
        }
        else {
            Set-ADUser -Identity $Script:User.SamAccountName -AuthType $AuthType -Server $Script:Domain.PDCEmulator -AccountExpirationDate $start
        }
    }
    Start-Sleep -Seconds 5 # wait
    if($PSCmdlet.ParameterSetName  -eq "Remote Jumphost"){
        $Script:User = Get-ADUser -Identity $Script:User.SAMAccountName -Properties * -Credential $DomainAccount -AuthType $AuthType -Server $Script:Domain.PDCEmulator
    }
    else{
        $Script:User = Get-ADUser -Identity $Script:User.SAMAccountName -Properties * -AuthType $AuthType -Server $Script:Domain.PDCEmulator
    }
    if([System.String]::IsNullOrWhiteSpace($Script:User.AccountExpirationDate)){
        $Out = "Account for user $($Username) never expires"
    }
    else{
        $Out=[System.TimeZone]::CurrentTimeZone.ToLocalTime([System.DateTime]::FromFileTimeUtc($Script:User.accountExpires))
        $Out = "Account for user $($Username) expires on the $($Out). Please inform the user in time."
    }
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