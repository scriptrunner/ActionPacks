#Requires -Version 5.0
#requires -Modules DFSN

<#
    .SYNOPSIS
        Returns the permissions for a DFS namespace folder

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
        https://github.com/scriptrunner/ActionPacks/tree/master/WinFileManagement/DFS/_QUERY_

    .Parameter FolderPath
        [sr-en] Path for a DFS namespace folder, e.g. \\server\namespace\foldername
        [sr-en] Pfad des DFS Namespace Ordners, z.B. \\server\namespace\foldername

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
                    'CimSession' = $cimSes
    }
    $objRights = Get-DfsnAccess @cmdArgs | Select-Object $Properties | Sort-Object AccountName

    foreach($acc in $objRights){
        if($null -ne $SRXEnv){
            $null = $SRXEnv.ResultList.Add($acc.AccountName)
            $null = $SRXEnv.ResultList2.Add($acc.AccountName)
        }
        else{
            Write-Output $acc.AccountName
        }
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