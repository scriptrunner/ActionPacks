#Requires -Version 5.0
#requires -Modules DFSN

<#
    .SYNOPSIS
        Adds a root target to a DFS namespace

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
        [sr-en] Path for the root folder of a DFS namespace, e.g. \\server\namespace
        [sr-de] Pfad des DFS-Namespaces, z.B. \\server\namespace
    
    .Parameter TargetPath
        [sr-en] Path for the target of a DFS namespace folder
        [sr-de] Zielordner mit Pfad

    .Parameter State
        [sr-en] State of the DFS namespace 
        [sr-de] Status des DFS-Namespace

    .Parameter ReferralPriorityClass
        [sr-en] Target priority class for a DFS namespace folder
        [sr-de] Priorität für den DFS-Namespace-Ordner

    .Parameter ReferralPriorityRank
        [sr-en] Priority rank for a target in the DFS namespace.
        [sr-de] Priorität-Position für den DFS-Namespace-Ordner

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
    [string]$TargetPath,
    [string]$Path,
    [ValidateSet('Online','Offline')]
    [string]$State,
    [ValidateSet('sitecostnormal','globalhigh','sitecosthigh','sitecostlow','globallow')]
    [uint32]$ReferralPriorityRank,
    [string]$ReferralPriorityClass,
    [string]$ComputerName,
    [PSCredential]$AccessAccount
)

Import-Module DFSN

$cimSes = $null
try{
    [hashtable]$cmdArgs = @{ErrorAction = 'Stop'}
    if([System.String]::IsNullOrWhiteSpace($ComputerName) -eq $false){
        $cmdArgs.Add('ComputerName', $ComputerName)
    }          
    if($null -ne $AccessAccount){
        $cmdArgs.Add('Credential', $AccessAccount)
    }
    $cimSes = New-CimSession @cmdArgs    

    $cmdArgs = @{ErrorAction = 'Stop'
                'CimSession' = $cimSes
                'Confirm' = $false
                'TargetPath' = $TargetPath
    }
    if($PSCmdlet.ParameterSetName -eq 'Path'){
        $cmdArgs.Add('Path',$Path)
    }
    if($PSBoundParameters.ContainsKey('State') -eq $true){
        $cmdArgs.Add('State',$State)
    }
    if($PSBoundParameters.ContainsKey('ReferralPriorityClass') -eq $true){
        $cmdArgs.Add('ReferralPriorityClass',$ReferralPriorityClass)
    }
    if($PSBoundParameters.ContainsKey('ReferralPriorityRank') -eq $true){
        $cmdArgs.Add('ReferralPriorityRank',$ReferralPriorityRank)
    }
    $objTargets = New-DfsnRootTarget @cmdArgs | Sort-Object Path | Select-Object *

    if($null -ne $SRXEnv){
        $SRXEnv.ResultMessage = $objTargets
    }
    else{
        Write-Output $objTargets
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