#Requires -Version 4.0
#Requires -Modules ActiveDirectory

<#
    .SYNOPSIS
        Lists users where disabled, inactive, locked out and/or account is expired
    
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
        https://github.com/scriptrunner/ActionPacks/tree/master/ActiveDirectory/_QUERY_

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
#
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$OUPath,  
    [PSCredential]$DomainAccount,
    [bool]$Disabled,
    [bool]$InActive ,
    [bool]$Locked ,
    [bool]$Expired ,
    [string]$DomainName,
    [ValidateSet('Base','OneLevel','SubTree')]
    [string]$SearchScope='SubTree',
    [ValidateSet('Basic', 'Negotiate')]
    [string]$AuthType="Negotiate"
)

Import-Module ActiveDirectory

try{
    $Script:users = @()
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
                'AuthType' = $AuthType
                'UsersOnly' = $null
                'Server' = $Domain.PDCEmulator
                'SearchBase' = $OUPath 
                'SearchScope' = $SearchScope
                }
    if($null -ne $DomainAccount){
        $cmdArgs.Add("Credential", $DomainAccount)
    }                
    if($Disabled -eq $true){
        $Script:users += Search-ADAccount @cmdArgs -AccountDisabled  `
                                | Select-Object DistinguishedName, SamAccountName | Sort-Object -Property SamAccountName
    }
    if($InActive -eq $true){
        $Script:users += Search-ADAccount @cmdArgs -AccountInactive  `
                                | Select-Object DistinguishedName, SamAccountName | Sort-Object -Property SamAccountName
    } 
    if($Locked -eq $true){
        $Script:users += Search-ADAccount @cmdArgs -LockedOut `
                                | Select-Object DistinguishedName, SamAccountName | Sort-Object -Property SamAccountName
    } 
    if($Expired -eq $true){
        $Script:users += Search-ADAccount @cmdArgs -AccountExpired `
                                | Select-Object DistinguishedName, SamAccountName | Sort-Object -Property SamAccountName
    } 
    
    if($null -ne $Script:users){
        foreach($itm in  $users){
            if($SRXEnv) {            
                $null = $SRXEnv.ResultList.Add($itm.DistinguishedName) # Value
                $null = $SRXEnv.ResultList2.Add($itm.SamAccountName) # DisplayValue            
            }
            else{
                Write-Output $itm.SamAccountName
            }
        }
    }
}
catch{
    throw
}
finally{
}