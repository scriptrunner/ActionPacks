#Requires -Version 4.0
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

    .COMPONENT
        Requires Module ActiveDirectory

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/ActiveDirectory/Users

    .Parameter OUPath
        Specifies the AD path

    .Parameter Username
        Display name, SAMAccountName, DistinguishedName or user principal name of an Active Directory account

    .Parameter DomainAccount
        Active Directory Credential for remote execution without CredSSP

    .Parameter Day
        Specifies the day of the expiration date for an Active Directory account

    .Parameter Month
        Specifies the month of the expiration date for an Active Directory account

    .Parameter Year
        Specifies the year of the expiration date for an Active Directory account
        
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

try{
    $Script:Domain 
    $Script:User 

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
        $Out=''
        $cmdArgs = @{'ErrorAction' = 'Stop'
                'Server' = $Domain.PDCEmulator
                'AuthType' = $AuthType
                'Identity' = $Script:User.SamAccountName
                }
        if($NeverExpires -eq $true){
           Set-ADUser @cmdArgs -AccountExpirationDate $null        
        }
        else{
            [datetime]$start = New-Object DateTime $Year, $Month, $Day
            if($start.ToFileTimeUtc() -lt [DateTime]::Now.ToFileTimeUtc()){
                Throw "Expiration date is in the past"
            }
            Set-ADUser @cmdArgs -AccountExpirationDate $start
        }
        Start-Sleep -Seconds 5 # wait
        $Script:User = Get-ADUser @cmdArgs -Properties *
        
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
}
catch{
    throw
}
finally{
}