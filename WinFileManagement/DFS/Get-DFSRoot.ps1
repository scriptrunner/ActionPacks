#Requires -Version 5.0
#requires -Modules DFSN

<#
    .SYNOPSIS
        Gets settings for DFS namespaces

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
    
    .Parameter Servername
        [sr-en] Name of a server
        [sr-de] Servername

    .Parameter ComputerName
        [sr-en] Name of the DFS computer
        [sr-de] DFS-Server 
        
    .Parameter AccessAccount
        [sr-en] User account that has permission to perform this action
        [sr-de] Ausreichend berechtigtes Benutzerkonto
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true,ParameterSetName = 'ServerName')]
    [string]$ServerName,
    [Parameter(Mandatory = $true,ParameterSetName = 'ByPath')]
    [string]$Path,
    [Parameter(ParameterSetName = 'ServerName')]
    [Parameter(ParameterSetName = 'ByPath')]
    [string]$ComputerName,
    [Parameter(ParameterSetName = 'ServerName')]
    [Parameter(ParameterSetName = 'ByPath')]
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
    }
    if($PSCmdlet.ParameterSetName -eq 'ServerName'){
        $cmdArgs.Add('Computername',$ServerName)
    }
    else{
        if($PSBoundParameters.ContainsKey('Path') -eq $true){
            $cmdArgs.Add('Path',$Path)
        }
    }
    $objRoot = Get-DfsnRoot @cmdArgs | Sort-Object Path | Select-Object *

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