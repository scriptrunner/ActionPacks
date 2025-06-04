#Requires -Version 5.0
#Requires -Modules ActiveDirectory

<#
    .SYNOPSIS
         Lists users where disabled, inactive, locked out and/or account is expired
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was originally developed for ScriptRunner and has been adapted for a non-ScriptRunner environment.

    .COMPONENT
        Requires Module ActiveDirectory

    .Parameter OUPath
        Specifies the AD path
        [sr-de] Active Directory Pfad

    .Parameter DomainAccount    
        Active Directory Credential for remote execution without CredSSP
        [sr-de] Active Directory-Benutzerkonto für die Remote-Ausführung ohne CredSSP        

    .Parameter Disabled
        Show the users where account disabled
        [sr-de] Benutzer anzeigen deren Konto deaktiviert ist
    
    .Parameter InActive
        Show the users where account inactive
        [sr-de] Benutzer anzeigen deren Konto inaktiv ist
        
    .Parameter Locked
        Show the users where account locked
        [sr-de] Benutzer anzeigen deren Konto gesperrt ist

    .Parameter Expired
        Show the users where account expired
        [sr-de] Benutzer anzeigen deren Konto abgelaufen ist

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
    [ValidateSet('Base','OneLevel','SubTree')]
    [string]$SearchScope='SubTree',
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [ValidateSet('Basic', 'Negotiate')]
    [string]$AuthType = "Negotiate"
)

Import-Module ActiveDirectory

try{
    $Script:resultMessage = @()
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
                'UsersOnly' = $null
                'SearchBase' = $OUPath 
                'SearchScope' = $SearchScope
                }
    if($null -ne $DomainAccount){
        $cmdArgs.Add("Credential", $DomainAccount)
    }               

    if($Disabled -eq $true){
        $users = Search-ADAccount @cmdArgs -AccountDisabled | Select-Object DistinguishedName, SAMAccountName | Sort-Object -Property SAMAccountName
        if($users){
            foreach($itm in  $users){
                $Script:resultMessage += ("Disabled: " + $itm.DistinguishedName + ';' +$itm.SamAccountName)
            }
            $Script:resultMessage += ''
        }
    }
    if($InActive -eq $true){
        $users = Search-ADAccount @cmdArgs -AccountInactive | Select-Object DistinguishedName, SAMAccountName | Sort-Object -Property SAMAccountName
        if($users){
            foreach($itm in  $users){
                $Script:resultMessage += ("Inactive: " + $itm.DistinguishedName + ';' +$itm.SamAccountName)            
            }
            $Script:resultMessage += ''
        }
    } 
    if($Locked -eq $true){
        $users = Search-ADAccount @cmdArgs -LockedOut | Select-Object DistinguishedName, SAMAccountName | Sort-Object -Property SAMAccountName        
        if($users){
            foreach($itm in  $users){
                $Script:resultMessage += ("Locked: " + $itm.DistinguishedName + ';' +$itm.SamAccountName)            
            }
            $Script:resultMessage += ''
        }
    } 
    if($Expired -eq $true){
        $users = Search-ADAccount @cmdArgs -AccountExpired | Select-Object DistinguishedName, SAMAccountName | Sort-Object -Property SAMAccountName
        if($users){
            foreach($itm in  $users){
                $Script:resultMessage += ("Expired: " + $itm.DistinguishedName + ';' +$itm.SamAccountName)            
            }
        }
    } 
    
    Write-Output $resultMessage
}
catch{
    throw
}
finally{
}