#Requires -Version 5.0
#requires -Modules DFSN

<#
    .SYNOPSIS
        Gets folder in a DFS namespace

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
        You can use DFS namespace with the wildcard character
        [sr-de] Pfad des DFS-Namespace-Ordners, z.B. \\server\namespace\foldername
        Wildcard-Zeichen werden unterstützt
    
    .Parameter Properties
        [sr-en] List of properties to expand. Use * for all properties
        [sr-de] Liste der zu anzuzeigenden Eigenschaften. Verwenden Sie * für alle Eigenschaften

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
    [ValidateSet('Path','State','Description','NamespacePath','TimeToLive','Flags','PSComputerName')]
    [string[]]$Properties = @('Path','State','Description','NamespacePath'),
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
                    'Path' = $FolderPath
                    'CimSession' = $cimSes
    }
    $objFolders = Get-DfsnFolder @cmdArgs | Sort-Object Path | Select-Object $Properties

    if($null -ne $SRXEnv){
        $SRXEnv.ResultMessage = $objFolders
    }
    else{
        Write-Output $objFolders
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