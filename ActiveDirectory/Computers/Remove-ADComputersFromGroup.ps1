#Requires -Version 5.0
#Requires -Modules ActiveDirectory

<#
    .SYNOPSIS
        Removes computers from Active Directory group
    
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
        https://github.com/scriptrunner/ActionPacks/tree/master/ActiveDirectory/Computers


    .Parameter OUPath
        [sr-en] Specifies the AD path
        [sr-de] Active Directory Pfad
        
    .Parameter GroupName
        [sr-en] Name of the group from which the computers are removed
        [sr-de] Name der Gruppe aus der die Computer gelöscht werden

    .Parameter ComputerNames
        [sr-en] Comma separated SID, SAMAccountName, DistinguishedName or GUID of the computers removed from the group
        [sr-de] Kommagetrennte SIDs, SamAccountNamen, Distinguished Namen oder GUIDs der Computer die aus der Gruppe gelöscht werden
       
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
    [string]$GroupName,
    [Parameter(Mandatory = $true,ParameterSetName = "Local or Remote DC")]
    [Parameter(Mandatory = $true,ParameterSetName = "Remote Jumphost")]
    [string[]]$ComputerNames,
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
    $Script:Domain = Get-ADDomain @cmdArgs    
    
    [string[]]$res = @()
    $cmdArgs = @{'ErrorAction' = 'Stop'
                'Server' = $Domain.PDCEmulator
                'AuthType' = $AuthType
                'Identity' = ""
                }
    [hashtable]$remArgs = @{'ErrorAction' = 'Stop'
                'Server' = $Domain.PDCEmulator
                'AuthType' = $AuthType
                'Confirm' = $false
                }
    if($null -ne $DomainAccount){
        $cmdArgs.Add("Credential", $DomainAccount)
        $remArgs.Add("Credential", $DomainAccount)
    }    

    [string[]]$cmpSAMAccountNames = @()
    foreach($name in ($ComputerNames.Split(','))){
        $cmdArgs["Identity"] = $name
        $comp = Get-ADComputer @cmdArgs | Select-Object SAMAccountName
        if($null -ne $comp){
            $cmpSAMAccountNames += $comp.SAMAccountName
        }
        else {
            $res = $res + "Computer $($name) not found"
        }
    }
   
    foreach($cmp in $cmpSAMAccountNames){
        $cmdArgs["Identity"] = $GroupName
        $grp = Get-ADGroup @cmdArgs
        if($null -ne $grp){
            try {
                Remove-ADGroupMember @remArgs -Identity $grp -Members $cmp
                $res = $res + "Computer $($cmp) removed from Group $($grp.Name)"
            }
            catch {
                $res = $res + "Error: Remove computer $($cmp) from Group $($grp.Name) $($_.Exception.Message)"
            }
        }
        else {
            $res = $res + "Group $($grp.Name) not found"
        }      
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