#Requires -Version 4.0
#Requires -Modules ActiveDirectory

<#
    .SYNOPSIS
         Removes users to Active Directory groups
    
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
        https://github.com/scriptrunner/ActionPacks/tree/master/ActiveDirectory/Users

    .Parameter OUPath
        Specifies the AD path
        [sr-de] Active Directory Pfad

    .Parameter UserNames
        Comma separated display name, SAMAccountName, DistinguishedName or user principal name of users removed from groups
        [sr-de] Kommagetrennte Anzeigenamen, SamAccountNamen, Distinguished Namen oder UPNs der Benutzer die aus den Gruppen gelöscht werden

    .Parameter GroupNames
        Comma separated names of the groups from which the users are removed
        [sr-de] Kommagetrennte Namen der Gruppen aus denen die Benutzer gelöscht werden
       
    .Parameter DomainAccount    
        Active Directory Credential for remote execution without CredSSP
        [sr-de] Active Directory-Benutzerkonto für die Remote-Ausführung ohne CredSSP        

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
    [string[]]$UserNames,
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
    [ValidateSet('Base','OneLevel','SubTree')]
    [string]$SearchScope='SubTree',
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
    $Script:Domain = Get-ADDomain @cmdArgs

    $cmdArgs = @{'ErrorAction' = 'Stop'
                'Server' = $Domain.PDCEmulator
                'AuthType' = $AuthType
                'Filter' = ""
                'SearchBase' = $OUPath 
                'SearchScope' = $SearchScope
                }
    $grpArgs = @{'ErrorAction' = 'Stop'
                'Server' = $Domain.PDCEmulator
                'AuthType' = $AuthType
                'Filter' = ""
                'SearchBase' = $OUPath 
                'SearchScope' = $SearchScope
                }
    $remArgs = @{'ErrorAction' = 'Stop'
                'Server' = $Domain.PDCEmulator
                'AuthType' = $AuthType
                'Confirm' = $false
                }
    if($null -ne $DomainAccount){
        $cmdArgs.Add("Credential", $DomainAccount)
        $grpArgs.Add("Credential", $DomainAccount)
        $remArgs.Add("Credential", $DomainAccount)
    }

    $res = @()
    $UserSAMAccountNames = @()
    if($UserNames){            
        foreach($name in $UserNames){
            $cmdArgs["Filter"] = {(SamAccountName -eq $name) -or (DisplayName -eq $name) -or (DistinguishedName -eq $name) -or (UserPrincipalName -eq $name)}
            $usr= Get-ADUser @cmdArgs | Select-Object SAMAccountName
            if($null -ne $usr){
                $UserSAMAccountNames += $usr.SAMAccountName
            }
            else {
                $res = $res + "User $($name) not found"
            }
        }
    }
    foreach($usr in $UserSAMAccountNames){
        $founded = @()
        foreach($itm in $GroupNames){
            $grpArgs["Filter"] = {(SamAccountName -eq $itm) -or (DistinguishedName -eq $itm)}
            $grp= Get-ADGroup @grpArgs
            if($null -ne $grp){
                $founded += $itm
                try {
                    Remove-ADGroupMember @remArgs -Identity $grp -Members $usr                    
                    $res = $res + "User $($usr) removed from Group $($itm)"
                }
                catch {
                    $res = $res + "Error: Remove user $($usr) from Group $($itm) $($_.Exception.Message)"
                }
            }
            else {
                $res = $res + "Group $($itm) not found"
            }        
        }
        $GroupNames=$founded
    }
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $res
    }
    else{
        Write-Output $res
    }   
}
catch{
    throw
}
finally{
}