#Requires -Version 4.0
#Requires -Modules ActiveDirectory

<#
    .SYNOPSIS
        Creates a group in the OU path
    
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
        https://github.com/scriptrunner/ActionPacks/tree/master/ActiveDirectory/Groups
        
    .Parameter OUPath
        Specifies the AD path
        [sr-de] Active Directory Pfad

    .Parameter GroupName
        Specifies the name of the new group
        [sr-de] Name der Gruppe
    
    .Parameter DomainAccount
        Active Directory Credential for remote execution on jumphost without CredSSP
        [sr-de] Active Directory-Benutzerkonto für die Remote-Ausführung ohne CredSSP        

    .Parameter SAMAccountName
        Specifies the Security Account Manager (SAM) account name of the group
        [sr-de] SAMAccountName der Gruppe

    .Parameter Description
        Specifies a description of the group
        [sr-de] Beschreibung der Gruppe

    .Parameter DisplayName
        Specifies the display name of the group
        [sr-de] Anzeigename der Gruppe

    .Parameter Scope
        Specifies the group scope of the group
        [sr-de] Gruppenbereich der Gruppe

    .Parameter Category
        Specifies the category of the group
        [sr-de] Kategorie der Gruppe

    .Parameter DomainName
        Name of Active Directory Domain
        [sr-de] Name der Active Directory Domäne
    
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
    [string]$SAMAccountName,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [string]$Description,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [string]$DisplayName,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [ValidateSet('DomainLocal', 'Global', 'Universal')]
    [string]$Scope = 'Universal',
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [ValidateSet('Distribution', 'Security')]
    [string]$Category = 'Security',  
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

    $cmdArgs = @{'ErrorAction' = 'Stop'
                'Server' = $Domain.PDCEmulator
                'AuthType' = $AuthType
                'PassThru' = $null
                'Confirm' = $false
                'SamAccountName' = $SAMAccountName 
                'DisplayName' = $DisplayName
                'Description' = $Description
                'Path' = $OUPath
                'Name' = $GroupName
                'GroupScope' = $Scope
                'GroupCategory' = $Category
                }
    if($null -ne $DomainAccount){
        $cmdArgs.Add("Credential", $DomainAccount)
    }
    $Script:Grp = New-ADGroup @cmdArgs

    if($null -ne $Script:Grp){
        if($SRXEnv) {
            $SRXEnv.ResultMessage = "Group $($Grp.DistinguishedName);$($Grp.SAMAccountName) created"
        } 
        else{
            Write-Output "Group $($Grp.DistinguishedName);$($Grp.SAMAccountName) created"
        }
    }   
}
catch{
    throw
}
finally{
}