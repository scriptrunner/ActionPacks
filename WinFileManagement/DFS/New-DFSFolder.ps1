#Requires -Version 5.0
#requires -Modules DFSN

<#
    .SYNOPSIS
        Creates a folder in a DFS namespace

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

    .Parameter FolderPath
        [sr-en] Path for the new DFS namespace folder, e.g. \\server\namespace\foldername
        [sr-de] Pfad des neuen DFS-Namespace-Ordner, z.B. \\server\namespace\foldername

    .Parameter TargetPath
        [sr-en] Path for a target for the DFS namespace folder
        [sr-de] Pfad des Zielordners für den DFS-Namespace-Ordner

    .Parameter State
        [sr-en] State of the DFS namespace folder
        [sr-de] Status des DFS-Namespace-Ordners

    .Parameter Description
        [sr-en] Description for a DFS namespace folder
        [sr-de] Beschreibung für den DFS-Namespace-Ordner

    .Parameter EnableInsiteReferrals
        [sr-en] DFS namespace server provides a client only with referrals that are in the same site as the client
        [sr-de] DFS-Server stellt einem Client nur Verweise zur Verfügung, die sich im selben Standort wie der Client befinden

    .Parameter EnableTargetFailback
        [sr-en] DFS namespace uses target failback
        [sr-de] Failback für DFS-Namespace

    .Parameter ReferralPriorityClass
        [sr-en] Target priority class for a DFS namespace folder
        [sr-de] Priorität für den DFS-Namespace-Ordner

    .Parameter ReferralPriorityRank
        [sr-en] Priority rank for a target in the DFS namespace.
        [sr-de] Priorität-Position für den DFS-Namespace-Ordner

    .Parameter TargetState
        [sr-en] State of the DFS namespace folder target
        [sr-de] Status des Zielordners

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
    [string]$FolderPath,
    [Parameter(Mandatory = $true)]
    [string]$TargetPath,
    [string]$Description,
    [bool]$EnableInsiteReferrals,
    [bool]$EnableTargetFailback,
    [uint32]$ReferralPriorityRank,
    [ValidateSet('Online','Offline')]
    [string]$State,
    [ValidateSet('sitecostnormal','globalhigh','sitecosthigh','sitecostlow','globallow')]
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
    [string[]]$Properties = @('Path','State','Description','NamespacePath','TimeToLive','Flags','PSComputerName')

    [hashtable]$cmdArgs = @{ErrorAction = 'Stop'}
    if([System.String]::IsNullOrWhiteSpace($ComputerName) -eq $false){
        $cmdArgs.Add('ComputerName', $ComputerName)
    }          
    if($null -ne $AccessAccount){
        $cmdArgs.Add('Credential', $AccessAccount)
    }
    $cimSes = New-CimSession @cmdArgs    

    $cmdArgs = @{ErrorAction = 'Stop'
                    'Path' = $FolderPath
                    'TargetPath' = $TargetPath
                    'CimSession' = $cimSes
                    'Confirm' = $false
    }
    if($PSBoundParameters.ContainsKey('Description') -eq $true){
        $cmdArgs.Add('Description',$Description)
    }
    if($PSBoundParameters.ContainsKey('EnableInsiteReferrals') -eq $true){
        $cmdArgs.Add('EnableInsiteReferrals',$EnableInsiteReferrals)
    }
    if($PSBoundParameters.ContainsKey('EnableTargetFailback') -eq $true){
        $cmdArgs.Add('EnableTargetFailback',$EnableTargetFailback)
    }
    if($PSBoundParameters.ContainsKey('ReferralPriorityClass') -eq $true){
        $cmdArgs.Add('ReferralPriorityClass',$ReferralPriorityClass)
    }
    if($PSBoundParameters.ContainsKey('ReferralPriorityRank') -eq $true){
        $cmdArgs.Add('ReferralPriorityRank',$ReferralPriorityRank)
    }
    if($PSBoundParameters.ContainsKey('State') -eq $true){
        $cmdArgs.Add('State',$State)
    }
    if($PSBoundParameters.ContainsKey('TargetState') -eq $true){
        $cmdArgs.Add('TargetState',$TargetState)
    }
    if($PSBoundParameters.ContainsKey('TimeToLiveSec') -eq $true){
        $cmdArgs.Add('TimeToLiveSec',$TimeToLiveSec)
    }
    $objFolder = New-DfsnFolder @cmdArgs | Select-Object $Properties

    if($null -ne $SRXEnv){
        $SRXEnv.ResultMessage = $objFolder
    }
    else{
        Write-Output $objFolder
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