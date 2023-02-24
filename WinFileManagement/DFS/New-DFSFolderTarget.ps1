#Requires -Version 5.0
#requires -Modules DFSN

<#
    .SYNOPSIS
        Adds a target to a DFS namespace folder

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
        [sr-en] Path of the DFS namespace folder, e.g. \\server\namespace\foldername
        [sr-de] Pfad des DFS-Namespace-Ordners, z.B. \\server\namespace\foldername

    .Parameter TargetPath
        [sr-en] Path for the new target for the DFS namespace folder
        [sr-de] Pfad des neuen Zielordners für den DFS-Namespace-Ordner

    .Parameter State
        [sr-en] State of the DFS namespace folder
        [sr-de] Status des DFS-Namespace-Ordners

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
    [string]$FolderPath,
    [Parameter(Mandatory = $true)]
    [string]$TargetPath,
    [ValidateSet('Online','Offline')]
    [string]$State,
    [uint32]$ReferralPriorityRank,
    [ValidateSet('sitecostnormal','globalhigh','sitecosthigh','sitecostlow','globallow')]
    [string]$ReferralPriorityClass,
    [string]$ComputerName,
    [PSCredential]$AccessAccount
)

Import-Module DFSN

$cimSes = $null
try{
    [string[]]$Properties = @('Path','State','TargetPath','NamespacePath')

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
    if($PSBoundParameters.ContainsKey('ReferralPriorityClass') -eq $true){
        $cmdArgs.Add('ReferralPriorityClass',$ReferralPriorityClass)
    }
    if($PSBoundParameters.ContainsKey('ReferralPriorityRank') -eq $true){
        $cmdArgs.Add('ReferralPriorityRank',$ReferralPriorityRank)
    }
    if($PSBoundParameters.ContainsKey('State') -eq $true){
        $cmdArgs.Add('State',$State)
    }
    $objTarget = New-DfsnFolderTarget @cmdArgs | Select-Object $Properties

    if($null -ne $SRXEnv){
        $SRXEnv.ResultMessage = $objTarget
    }
    else{
        Write-Output $objTarget
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