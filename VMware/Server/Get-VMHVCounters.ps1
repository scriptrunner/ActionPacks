#Requires -Version 4.0
# Requires -Modules VMware.PowerCLI

<#
.SYNOPSIS
    Retrieves the available counters

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
    https://github.com/scriptrunner/ActionPacks/tree/master/VMware/Server

.Parameter VIServer
    Specifies the IP address or the DNS name of the vSphere server to which you want to connect

.Parameter VICredential
    Specifies a PSCredential object that contains credentials for authenticating with the server

.Parameter CounterName
    Specifies the name of the counter you want to retrieve, is the parameter empty all counters retrieved

.Parameter Properties
    List of properties to expand, comma separated e.g. Name,Fields. Use * for all properties
    
.Parameter ExpandFields
    Retrieve the expanded property fields
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential,
    [string]$CounterName,
    [ValidateSet('*','Name','UId','Fields')]
    [string[]]$Properties = @('Name','UId','Fields'),
    [switch]$ExpandFields
)

Import-Module VMware.PowerCLI

try{
    if($Properties -contains '*'){
        $Properties = @('*')
    }
    if([System.String]::IsNullOrWhiteSpace($CounterName) -eq $true){
        $CounterName = "*"
    }
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop

    if($ExpandFields -eq $false){
        $Script:Output = Get-EsxTop -Server $Script:vmServer -Counter -CounterName $CounterName -ErrorAction Stop | Select-Object $Properties
    }
    else{
        $Script:Output = Get-EsxTop -Server $Script:vmServer -Counter -CounterName $CounterName -ErrorAction Stop | Select-Object -ExpandProperty Fields
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