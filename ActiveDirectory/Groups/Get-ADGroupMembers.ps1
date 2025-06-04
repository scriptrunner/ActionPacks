#Requires -Version 5.0
#Requires -Modules ActiveDirectory

<#
    .SYNOPSIS
        Gets the members of the Active Directory group
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was originally developed for ScriptRunner and has been adapted for a non-ScriptRunner environment.

    .COMPONENT
        Requires Module ActiveDirectory

    .Parameter OUPath
        Specifies the AD path
        [sr-de] Active Directory Pfad

    .Parameter GroupName
        DistinguishedName or SamAccountName of the Active Directory group
        [sr-de] SAMAccountName oder Distinguished-Name der Gruppe

    .Parameter DomainAccount
        Active Directory Credential for remote execution on jumphost without CredSSP
        [sr-de] Active Directory-Benutzerkonto für die Remote-Ausführung ohne CredSSP        

    .Parameter Nested
        Shows group members nested 
        [sr-de] Gruppenmitglieder rekursiv anzeigen
        
    .Parameter ShowOnlyGroups
        Shows only Active Directory groups
        [sr-de] Nur Gruppen anzeigen

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
    [Parameter(Mandatory = $true,ParameterSetName = "Local or Remote DC")]
    [Parameter(Mandatory = $true,ParameterSetName = "Remote Jumphost")]
    [string]$GroupName,
    [Parameter(Mandatory = $true,ParameterSetName = "Remote Jumphost")]
    [PSCredential]$DomainAccount,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [switch]$Nested,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [switch]$ShowOnlyGroups,
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
    $Script:Grp
    $Script:resultMessage = @()

    function Get-NestedGroupMember($group) { 
        $Script:resultMessage += "Group: $($group.DistinguishedName);$($group.SamAccountName)"
        [hashtable]$searchArgs = @{'ErrorAction' = 'Stop'
                                    'Server' = $Script:Domain.PDCEmulator
                                    'AuthType' = $AuthType
                                    'Identity' = $group
                                    }
        if($null -ne $DomainAccount){
            $searchArgs.Add("Credential", $DomainAccount)
        }                                    
        $members =Get-ADGroupMember @searchArgs | `
        Sort-Object -Property  @{Expression="objectClass";Descending=$true} , @{Expression="SamAccountName";Descending=$false}
    
        if($null -ne $members){
            foreach($itm in $members){
                if($itm.objectClass -eq "group"){
                    if($Nested -eq $true){
                        Get-NestedGroupMember($itm)
                    }
                    else{
                        $Script:resultMessage += "Group: $($itm.DistinguishedName);$($itm.SamAccountName)"
                    }
                }
                else{
                    if($ShowOnlyGroups -eq $false){
                        $Script:resultMessage += "User: $($itm.DistinguishedName);$($itm.SamAccountName)"
                    }
                }
            }
        }
    }
       
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
    $Script:Domain = Get-ADDomain @cmdArgs

    $cmdArgs = @{'ErrorAction' = 'Stop'
                'Server' = $Script:Domain.PDCEmulator
                'AuthType' = $AuthType
                'Identity' =  $GroupName
                }
    if($null -ne $DomainAccount){
        $cmdArgs.Add("Credential", $DomainAccount)
    }    
    $Script:Grp = Get-ADGroup @cmdArgs

    if($null -ne $Script:Grp){    
        Get-NestedGroupMember $Script:Grp
        Write-Output $Script:resultMessage
    }
    else{
        throw "Group $($GroupName) not found"
    }   
}
catch{
    throw
}
finally{
}