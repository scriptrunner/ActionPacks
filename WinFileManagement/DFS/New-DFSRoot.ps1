#Requires -Version 5.0
#requires -Modules DFSN

<#
    .SYNOPSIS
        Creates a DFS namespace

    .DESCRIPTION

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT    

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/WinFileManagement/DFS

    .Parameter Path
        [sr-en] Path for the root of a DFS namespace, e.g. \\server\namespace
        [sr-de] Pfad des DFS-Namespaces, z.B. \\server\namespace

    .Parameter TargetPath
        [sr-en] Path for a root target of the DFS namespace, e.g. \\server\folder
        [sr-de] Pfad des Zielordners des DFS-Namespaces, z.B. \\server\ordner

    .Parameter Description
        [sr-en] Description of the DFS namespace
        [sr-de] DFS-Namespace Beschreibung

    .Parameter Type
        [sr-en] Type of a DFS namespace
        [sr-de] Typ des DFS-Namespaces

    .Parameter EnableAccessBasedEnumeration
        [sr-en] DFS namespace uses access-based enumeration
        [sr-de] Access-Based Enumeration

    .Parameter EnableInsiteReferrals
        [sr-en] DFS namespace server provides a client only with referrals that are in the same site as the client
        [sr-de] DFS-Namensraumserver stellt einem Client nur Verweise zur Verfügung, die sich am selben Standort wie der Client befinden

    .Parameter EnableRootScalability
        [sr-en] DFS namespace uses root scalability mode.
        [sr-de] DFS-Namespace nutzt Root-Skalierungsmodus

    .Parameter EnableSiteCosting
        [sr-en] DFS namespace uses cost-based selection.
        [sr-de] DFS-Namespace verwendet eine kostenbasierte Auswahl

    .Parameter EnableTargetFailback
        [sr-en] DFS namespace uses target failback
        [sr-de] DFS-Namespace verwendet Failback

    .Parameter GrantAdminAccounts
        [sr-en] Grants management permissions for the DFS namespace to the users and user groups, domain\accountname
        [sr-de] Zugriffsrecht auf den DFS-Namespace für Benutzer und Gruppen, domain\accountname

    .Parameter State
        [sr-en] State of the DFS namespace 
        [sr-de] Status des DFS-Namespace

    .Parameter TargetState
        [sr-en] State of the DFS namespace folder target
        [sr-de] Status des Zielordners

    .Parameter ReferralPriorityClass
        [sr-en] Target priority class for a DFS namespace folder
        [sr-de] Priorität für den DFS-Namespace-Ordner

    .Parameter ReferralPriorityRank
        [sr-en] Priority rank for a target in the DFS namespace.
        [sr-de] Priorität-Position für den DFS-Namespace-Ordner

    .Parameter TimeToLiveSec
        [sr-en] TTL interval, in seconds, for referrals
        [sr-de] TTL Intervall, in Sekunden, für Verweise

    .Parameter ComputerName
        [sr-en] Name of the DFS computer
        [sr-de] DFS-Server 
        
    .Parameter AccessAccount
        [sr-en] User account that has permission to perform this action
        [sr-de] Ausreichend berechtigtes Benutzerkonto
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$Path,
    [Parameter(Mandatory = $true)]
    [string]$TargetPath,
    [Parameter(Mandatory = $true)]
    [ValidateSet('Standalone','DomainV1','DomainV2')]
    [string]$Type = 'DomainV2',
    [string]$Description,
    [bool]$EnableAccessBasedEnumeration,
    [bool]$EnableInsiteReferrals,
    [bool]$EnableRootScalability,
    [bool]$EnableSiteCosting,
    [bool]$EnableTargetFailback,
    [string[]]$GrantAdminAccounts,
    [ValidateSet('Online','Offline')]
    [string]$State,
    [ValidateSet('sitecostnormal','globalhigh','sitecosthigh','sitecostlow','globallow')]
    [uint32]$ReferralPriorityRank,
    [string]$ReferralPriorityClass,
    [ValidateSet('Online','Offline')]
    [string]$TargetState,
    [int]$TimeToLiveSec,
    [string]$ComputerName,
    [PSCredential]$AccessAccount
)

Import-Module DFSN

$cimSes = $null
try{
    [string[]]$Properties = @('State','Flags','Type','Path','TimeToLiveSec','Description','NamespacePath','TimeToLive','GrantAdminAccess','PSComputerName')
    [hashtable]$cmdArgs = @{ErrorAction = 'Stop'}
    if([System.String]::IsNullOrWhiteSpace($ComputerName) -eq $false){
        $cmdArgs.Add('ComputerName', $ComputerName)
    }          
    if($null -ne $AccessAccount){
        $cmdArgs.Add('Credential', $AccessAccount)
    }
    $cimSes = New-CimSession @cmdArgs    

    $cmdArgs = @{ErrorAction = 'Stop'
                'Path' = $Path
                'TargetPath' = $TargetPath
                'Type' = $Type
                'Confirm' = $false
                'CimSession' = $cimSes
    }    
    if($PSBoundParameters.ContainsKey('Description') -eq $true){
        $cmdArgs.Add('Description',$Description)
    }    
    if($PSBoundParameters.ContainsKey('EnableAccessBasedEnumeration') -eq $true){
        $cmdArgs.Add('EnableAccessBasedEnumeration',$EnableAccessBasedEnumeration)
    }
    if($PSBoundParameters.ContainsKey('EnableInsiteReferrals') -eq $true){
        $cmdArgs.Add('EnableInsiteReferrals',$EnableInsiteReferrals)
    }
    if($PSBoundParameters.ContainsKey('EnableRootScalability') -eq $true){
        $cmdArgs.Add('EnableRootScalability',$EnableRootScalability)
    }
    if($PSBoundParameters.ContainsKey('EnableSiteCosting') -eq $true){
        $cmdArgs.Add('EnableSiteCosting',$EnableSiteCosting)
    }
    if($PSBoundParameters.ContainsKey('EnableTargetFailback') -eq $true){
        $cmdArgs.Add('EnableTargetFailback',$EnableTargetFailback)
    }
    if($PSBoundParameters.ContainsKey('GrantAdminAccounts') -eq $true){
        $cmdArgs.Add('GrantAdminAccounts',$GrantAdminAccounts)
    }
    if($PSBoundParameters.ContainsKey('State') -eq $true){
        $cmdArgs.Add('State',$State)
    }
    if($PSBoundParameters.ContainsKey('TargetState') -eq $true){
        $cmdArgs.Add('TargetState',$TargetState)
    }
    if($PSBoundParameters.ContainsKey('ReferralPriorityClass') -eq $true){
        $cmdArgs.Add('ReferralPriorityClass',$ReferralPriorityClass)
    }
    if($PSBoundParameters.ContainsKey('ReferralPriorityRank') -eq $true){
        $cmdArgs.Add('ReferralPriorityRank',$ReferralPriorityRank)
    }
    if($PSBoundParameters.ContainsKey('TimeToLiveSec') -eq $true){
        $cmdArgs.Add('TimeToLiveSec',$TimeToLiveSec)
    }
    $objRoot = New-DfsnRoot @cmdArgs | Sort-Object Path | Select-Object $Properties

    if($null -ne $SRXEnv){
        $SRXEnv.ResultMessage = $objRoot
    }
    else{
        Write-Output $objRoot
    }
}
catch{
    throw
}
finally{
    if($null -ne $cimSes){
        Remove-CimSession $cimSes
    }
}