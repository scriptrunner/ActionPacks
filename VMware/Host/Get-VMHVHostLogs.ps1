#Requires -Version 4.0
# Requires -Modules VMware.PowerCLI

<#
.SYNOPSIS
    Retrieves entries from vSphere logs

.DESCRIPTION

.NOTES
    This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
    The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
    The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
    © ScriptRunner Software GmbH

.COMPONENT
    Requires Module VMware.PowerCLI

.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/VMware/Host

.Parameter VIServer
    Specifies the IP address or the DNS name of the vSphere server to which you want to connect

.Parameter VICredential
    Specifies a PSCredential object that contains credentials for authenticating with the server

.Parameter HostName
    Specifies the name of the host you want to retrieve logs

.Parameter LogFileKey
    Specifies the key identifier of the log file you want to retrieve. 
    If the parameter is empty, the first key of the log types is used

.Parameter StartLineNumber
    Specifies the start line number for reading from the logs

.Parameter LineNumbers
    Specifies the number of the lines you want to retrieve from the logs

.Parameter Bundle
    Indicates whether to retrieve a diagnostic bundle of logs from vCenter Server

.Parameter DestinationPath
    Specifies a local file path where you want to save the log bundle
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true)]
    [string]$HostName,
    [string]$LogFileKey,
    [int32]$StartLineNumber = 1,
    [int32]$LineNumbers = 20,
    [switch]$Bundle,
    [string]$DestinationPath
)

Import-Module VMware.PowerCLI

try{    
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
    $Script:vmHost = Get-VMHost -Server $Script:vmServer -Name $HostName -ErrorAction Stop

    if($Bundle -eq $true){
        $Script:Output = Get-Log -Server $Script:vmServer -VMHost $Script:vmHost -Bundle -DestinationPath $DestinationPath `
                            -ErrorAction Stop
    }
    else {
        if([System.String]::IsNullOrWhiteSpace($LogFileKey) -eq $true){
            $LogFileKey = Get-LogType -Server $Script:vmServer -VMHost $Script:vmHost -ErrorAction Stop | Select-Object -First 1 -ExpandProperty Key
        }
        $Script:Output = Get-Log -Server $Script:vmServer -VMHost $Script:vmHost -Key $LogFileKey -StartLineNum $StartLineNumber `
                            -NumLines $LineNumbers -ErrorAction Stop | Select-Object -ExpandProperty Entries
    }

    if($SRXEnv) {
        $SRXEnv.ResultMessage = $Script:Output 
    }
    else{
        Write-Output $Script:Output
    }
}
catch{
    throw
}
finally{    
    if($null -ne $Script:vmServer){
        Disconnect-VIServer -Server $Script:vmServer -Force -Confirm:$false
    }
}