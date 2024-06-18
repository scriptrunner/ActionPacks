#Requires -Version 5.0
#requires -Modules DFSN

<#
    .SYNOPSIS
        Removes a target for a DFS namespace root

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
        [sr-en] Path of the DFS namespace, e.g. \\server\namespace
        [sr-de] Pfad des DFS-Namespaces, z.B. \\server\namespace
    
    .Parameter TargetPath
        [sr-en] Path for the target of a DFS namespace folder
        [sr-de] Zielordner mit Pfad
    
    .Parameter CleanUp
        [sr-en] Clean-up of the root target in Active Directory Domain Services (AD DS)
        [sr-de] Bereinigung des Stammziels in Active Directory Domain Services (AD DS) erzwingen

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
    [switch]$CleanUp,
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
                'TargetPath' = $TargetPath
                'Confirm' = $false
    }
    if($PSCmdlet.ParameterSetName -eq 'Path'){
        $cmdArgs.Add('Path',$Path)
    }
    if($CleanUp.IsPresent -eq $true){
        $cmdArgs.Add('Cleanup',$CleanUp)
    }
    $objTargets = Remove-DfsnRootTarget @cmdArgs | Sort-Object Path | Select-Object *

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