#Requires -Version 4.0
# Requires -Modules VMware.PowerCLI

<#
.SYNOPSIS
    Retrieves information about the current or recent tasks

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
    https://github.com/scriptrunner/ActionPacks/tree/master/VMware/Tasks

.Parameter VIServer
    Specifies the IP address or the DNS name of the vSphere server to which you want to connect

.Parameter VICredential
    Specifies a PSCredential object that contains credentials for authenticating with the server

.Parameter Status
    Specifies the status of the tasks you want to retrieve

.Parameter Properties
    List of properties to expand, comma separated e.g. Description,StartTime. Use * for all properties
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential,
    [ValidateSet("Error","Queued","Running","Success")]
    [string]$Status,
    [ValidateSet('*','Description','State','IsCancelable','StartTime','FinishTime','PercentComplete','Name')]
    [string[]]$Properties = @('Description','State','IsCancelable','StartTime','FinishTime','PercentComplete','Name')
)

Import-Module VMware.PowerCLI

try{
    if($Properties -contains '*'){
        $Properties = @('*')
    }
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
    
    if([System.String]::IsNullOrWhiteSpace($Status) -eq $true){
        $Script:Output = Get-Task -Server $Script:vmServer -ErrorAction Stop | Select-Object $Properties
    }
    else {
        $Script:Output = Get-Task -Server $Script:vmServer -Status $Status -ErrorAction Stop | Select-Object $Properties
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