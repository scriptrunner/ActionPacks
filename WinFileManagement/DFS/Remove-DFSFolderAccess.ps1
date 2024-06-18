#Requires -Version 5.0
#requires -Modules DFSN

<#
    .SYNOPSIS
        Removes users and groups from the ACL for a folder in a DFS namespace

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
        [sr-en] Path for a DFS namespace folder, e.g. \\server\namespace\foldername
        [sr-de] Pfad des DFS Namespace Ordners, z.B. \\server\namespace\foldername

    .Parameter AccountName
        [sr-en] User or group account
        [sr-de] Benutzer- oder Gruppen-Name

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
    [string]$AccountName,
    [string]$ComputerName,
    [PSCredential]$AccessAccount
)

Import-Module DFSN

$cimSes = $null
try{
    $Properties = @('AccountName','AccessType','Path','NamespacePath','PSComputerName')

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
                    'AccountName' = $AccountName
                    'CimSession' = $cimSes
                    'Confirm' = $false
    }
    $objRights = Remove-DfsnAccess @cmdArgs | Select-Object $Properties | Sort-Object AccountName

    if($null -ne $SRXEnv){
        $SRXEnv.ResultMessage = $objRights
    }
    else{
        Write-Output $objRights
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