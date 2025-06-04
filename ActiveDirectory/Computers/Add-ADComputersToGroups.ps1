#Requires -Version 5.0
#Requires -Modules ActiveDirectory

<#
    .SYNOPSIS
        Adds computers to Active Directory groups
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was originally developed for ScriptRunner and has been adapted for a non-ScriptRunner environment.

    .COMPONENT
        Requires Module ActiveDirectory

    .Parameter OUPath
        [sr-en] Specifies the AD path
        [sr-de] Active Directory Pfad

    .Parameter ComputerNames
        [sr-en] Comma separated SAMAccountName, SID, DistinguishedName or GUID of the computers added to the groups
        [sr-de] Kommagetrennte SIDs, SamAccountNamen, Distinguished Namen oder GUIDs der Computer die zu den Gruppen hinzugefügt werden

    .Parameter GroupNames
        [sr-en] Comma separated names of the groups to which the computers added
        [sr-de] Kommagetrennte Namen der Gruppen zu denen die Computer hinzugefügt werden
       
    .Parameter DomainAccount
        [sr-en] Active Directory Credential for remote execution without CredSSP
        [sr-de] Active Directory-Benutzerkonto für die Remote-Ausführung ohne CredSSP    

    .Parameter DomainName
        [sr-en] Name of Active Directory Domain
        [sr-de] Name der Active Directory Domäne
    
    .Parameter AuthType
        [sr-en] Specifies the authentication method to use
        [sr-de] Gibt die zu verwendende Authentifizierungsmethode an
#>

param(
    [Parameter(Mandatory = $true,ParameterSetName = "Local or Remote DC")]
    [Parameter(Mandatory = $true,ParameterSetName = "Remote Jumphost")]
    [string]$OUPath,
    [Parameter(Mandatory = $true,ParameterSetName = "Local or Remote DC")]
    [Parameter(Mandatory = $true,ParameterSetName = "Remote Jumphost")]
    [string[]]$ComputerNames,
    [Parameter(Mandatory = $true,ParameterSetName = "Local or Remote DC")]
    [Parameter(Mandatory = $true,ParameterSetName = "Remote Jumphost")]
    [string[]]$GroupNames,
    [Parameter(Mandatory = $true,ParameterSetName = "Remote Jumphost")]
    [PSCredential]$DomainAccount,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [string]$DomainName,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [ValidateSet('Basic', 'Negotiate')]
    [string]$AuthType="Negotiate" 
)

Import-Module ActiveDirectory

try{    
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
    
    [string[]]$res = @()
    [string[]]$cmpSAMAccountNames = @()
    $cmdArgs = @{'ErrorAction' = 'Stop'
                'Server' = $Domain.PDCEmulator
                'AuthType' = $AuthType
                'Identity' = ''                
                }
    if($null -ne $DomainAccount){
        $cmdArgs.Add("Credential", $DomainAccount)
    }
    foreach($name in ($ComputerNames.Split(','))){
        $cmdArgs.Item("Identity") = $name
        $cmp= Get-ADComputer @cmdArgs | Select-Object SAMAccountName
        if($null -ne $cmp){
            $cmpSAMAccountNames += $cmp.SAMAccountName
        }
        else {
            $res = $res + "Computer $($name) not found"
        }
    }
     
    [hashtable]$groupArgs = @{'ErrorAction' = 'Stop'
                            'AuthType' = $AuthType
                            'Server' = $Domain.PDCEmulator
                            'Identity' = ''
                            }
    $cmdArgs = @{'ErrorAction' = 'Stop'
                'Server' = $Domain.PDCEmulator
                'AuthType' = $AuthType
                }
    if($null -ne $DomainAccount){
        $cmdArgs.Add("Credential", $DomainAccount)
        $groupArgs.Add("Credential", $DomainAccount)
    }
    foreach($comp in $cmpSAMAccountNames){
        foreach($itm in ($GroupNames.Split(','))){
            $groupArgs.Item("Identity") = $itm
            $grp= Get-ADGroup @groupArgs
            
            if($null -ne $grp){
                try {
                    Add-ADGroupMember @cmdArgs -Identity $grp -Members $comp
                    $res = $res + "Computer $($comp) added to Group $($itm)"
                }
                catch {
                    $res = $res + "Error: Add computer $($comp) to Group $($itm) $($_.Exception.Message)"
                }
            }
            else {
                $res = $res + "Group $($itm) not found"
            }        
        }
    }
    Write-Output $res
}
catch{
    throw
}
finally{
}