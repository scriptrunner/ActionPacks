#Requires -Modules ActiveDirectory

<#
    .SYNOPSIS
         Lists users where disabled, inactive, locked out and/or account is expired
    
    .DESCRIPTION
          
    .Parameter OUPath
        Specifies the AD path

    .Parameter DomainAccount
        Active Directory Credential

    .Parameter Disabled
        Show the users where account disabled
    
    .Parameter InActive
        Show the users where account inactive
        
    .Parameter Locked
        Show the users where account locked

    .Parameter Expired
        Show the users where account expired

    .Parameter DomainName
        Name of Active Directory Domain
    
    .Parameter AuthType
        Specifies the authentication method to use
#>

param(
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [string]$OUPath,
    [Parameter(Mandatory = $true,ParameterSetName = "Remote Jumphost")]
    [PSCredential]$DomainAccount,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [switch]$Disabled,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [switch]$InActive,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [switch]$Locked,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [switch]$Expired,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [string]$DomainName,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [ValidateSet('Basic', 'Negotiate')]
    [string]$AuthType="Negotiate"
)

Import-Module ActiveDirectory

#Clear
$ErrorActionPreference='Stop'

$resultMessage = @()

if([System.String]::IsNullOrWhiteSpace($OUPath)){
    $OUPath = $Domain.DistinguishedName
}
if($PSCmdlet.ParameterSetName  -eq "Remote Jumphost"){
    if([System.String]::IsNullOrWhiteSpace($DomainName)){
        $Domain = Get-ADDomain -Current LocalComputer -AuthType $AuthType -Credential $DomainAccount
    }
    else{
        $Domain = Get-ADDomain -Identity $DomainName -AuthType $AuthType -Credential $DomainAccount
    }    
    if([System.String]::IsNullOrWhiteSpace($OUPath)){
        $OUPath = $Domain.DistinguishedName
    }
    if($Disabled -eq $true){
        $users = Search-ADAccount -Server $Domain.PDCEmulator -Credential $DomainAccount -AuthType $AuthType -AccountDisabled -UsersOnly -SearchBase $OUPath | Select-Object DistinguishedName, SAMAccountName | Sort-Object -Property SAMAccountName
        if($users){
            foreach($itm in  $users){
                $resultMessage = $resultMessage + ("Disabled: " + $itm.DistinguishedName + ';' +$itm.SamAccountName)
            }
            $resultMessage = $resultMessage + ''
        }
    }
    if($InActive -eq $true){
        $users = Search-ADAccount -Server $Domain.PDCEmulator -Credential $DomainAccount -AuthType $AuthType -AccountInactive -UsersOnly -SearchBase $OUPath | Select-Object DistinguishedName, SAMAccountName | Sort-Object -Property SAMAccountName
        if($users){
            foreach($itm in  $users){
               $resultMessage = $resultMessage + ("Inactive: " + $itm.DistinguishedName + ';' +$itm.SamAccountName)            
            }
            $resultMessage = $resultMessage + ''
        }
    } 
    if($Locked -eq $true){
        $users = Search-ADAccount -Server $Domain.PDCEmulator -Credential $DomainAccount -AuthType $AuthType -LockedOut -UsersOnly -SearchBase $OUPath | Select-Object DistinguishedName, SAMAccountName | Sort-Object -Property SAMAccountName
        if($users){
            foreach($itm in  $users){
               $resultMessage = $resultMessage + ("Locked: " + $itm.DistinguishedName + ';' +$itm.SamAccountName)            
            }
            $resultMessage = $resultMessage + ''
        }
    } 
    if($Expired -eq $true){
        $users = Search-ADAccount -Server $Domain.PDCEmulator -Credential $DomainAccount -AuthType $AuthType -AccountExpired -UsersOnly -SearchBase $OUPath | Select-Object DistinguishedName, SAMAccountName | Sort-Object -Property SAMAccountName
        if($users){
            foreach($itm in  $users){
               $resultMessage = $resultMessage + ("Expired: " + $itm.DistinguishedName + ';' +$itm.SamAccountName)            
            }
        }
    } 
}
else{
    if([System.String]::IsNullOrWhiteSpace($DomainName)){
        $Domain = Get-ADDomain -Current LocalComputer -AuthType $AuthType 
    }
    else{
        $Domain = Get-ADDomain -Identity $DomainName -AuthType $AuthType 
    }    
    if([System.String]::IsNullOrWhiteSpace($OUPath)){
        $OUPath = $Domain.DistinguishedName
    }
    if($Disabled -eq $true){
        $users = Search-ADAccount -Server $Domain.PDCEmulator -AuthType $AuthType -AccountDisabled -UsersOnly -SearchBase $OUPath | Select-Object DistinguishedName, SAMAccountName | Sort-Object -Property SAMAccountName
        if($users){
            foreach($itm in  $users){
                $resultMessage = $resultMessage + ("Disabled: " + $itm.DistinguishedName + ';' +$itm.SamAccountName)
            }
            $resultMessage = $resultMessage + ''
        }
    }
    if($InActive -eq $true){
        $users = Search-ADAccount -Server $Domain.PDCEmulator -AuthType $AuthType -AccountInactive -UsersOnly -SearchBase $OUPath | Select-Object DistinguishedName, SAMAccountName | Sort-Object -Property SAMAccountName
        if($users){
            foreach($itm in  $users){
               $resultMessage = $resultMessage + ("Inactive: " + $itm.DistinguishedName + ';' +$itm.SamAccountName)            
            }
            $resultMessage = $resultMessage + ''
        }
    } 
    if($Locked -eq $true){
        $users = Search-ADAccount -Server $Domain.PDCEmulator -AuthType $AuthType -LockedOut -UsersOnly -SearchBase $OUPath | Select-Object DistinguishedName, SAMAccountName | Sort-Object -Property SAMAccountName
        if($users){
            foreach($itm in  $users){
               $resultMessage = $resultMessage + ("Locked: " + $itm.DistinguishedName + ';' +$itm.SamAccountName)            
            }
            $resultMessage = $resultMessage + ''
        }
    } 
    if($Expired -eq $true){
        $users = Search-ADAccount -Server $Domain.PDCEmulator -AuthType $AuthType -AccountExpired -UsersOnly -SearchBase $OUPath | Select-Object DistinguishedName, SAMAccountName | Sort-Object -Property SAMAccountName
        if($users){
            foreach($itm in  $users){
               $resultMessage = $resultMessage + ("Expired: " + $itm.DistinguishedName + ';' +$itm.SamAccountName)            
            }
        }
    } 
} 
if($SRXEnv) {
    $SRXEnv.ResultMessage = $resultMessage 
}
else{
    Write-Output $resultMessage 
}