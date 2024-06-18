#Requires -Version 5.0
# Requires -Modules VMware.VimAutomation.Core

<#
    .SYNOPSIS
        Retrieves the hosts on a vCenter Server system

    .DESCRIPTION

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires Module VMware.VimAutomation.Core

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/VMware/Host

    .Parameter VIServer
        [sr-en] IP address or the DNS name of the vSphere server to which you want to connect
        [sr-de] IP Adresse oder DNS des vSphere Servers

    .Parameter VICredential
        [sr-en] PSCredential object that contains credentials for authenticating with the server
        [sr-de] Benutzerkonto für die Ausführung

    .Parameter ID
        [sr-en] ID of the host you want to retrieve
        [sr-de] Id des Hosts

    .Parameter Name
        [sr-en] Name of the host you want to retrieve, is the parameter empty all hosts retrieved
        [sr-de] Hostname

    .Parameter Datastore
        [sr-en] Datastore or datastore cluster to which the host that you want to retrieve are associated
        [sr-de] Datastore oder Cluster

    .Parameter VM
        [sr-en] Virtual machine whose host you want to retrieve
        [sr-de] Virtuelle Maschine

    .Parameter NoRecursion
        [sr-en] Disable the recursive behavior
        [sr-de] Rekursives Verhalten deaktivieren

    .Parameter Properties
        [sr-en] List of properties to expand. Use * for all properties
        [sr-de] Liste der zu anzuzeigenden Eigenschaften. Verwenden Sie * für alle Eigenschaften
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true,ParameterSetName = "byID")]
    [Parameter(Mandatory = $true,ParameterSetName = "byName")]
    [Parameter(Mandatory = $true,ParameterSetName = "byDatastore")]
    [Parameter(Mandatory = $true,ParameterSetName = "byResourcePool")]
    [Parameter(Mandatory = $true,ParameterSetName = "byVM")]
    [string]$VIServer,
    [Parameter(Mandatory = $true,ParameterSetName = "byID")]
    [Parameter(Mandatory = $true,ParameterSetName = "byName")]
    [Parameter(Mandatory = $true,ParameterSetName = "byDatastore")]
    [Parameter(Mandatory = $true,ParameterSetName = "byResourcePool")]
    [Parameter(Mandatory = $true,ParameterSetName = "byVM")]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true,ParameterSetName = "byID")]
    [string]$ID,
    [Parameter(Mandatory = $true,ParameterSetName = "byDatastore")]
    [string]$Datastore,    
    [Parameter(Mandatory = $true,ParameterSetName = "byResourcePool")]
    [string]$ResourcePool,
    [Parameter(Mandatory = $true,ParameterSetName = "byVM")]
    [string]$VM,
    [Parameter(ParameterSetName = "byName")]
    [string]$Name,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [Parameter(ParameterSetName = "byDatastore")]
    [Parameter(ParameterSetName = "byResourcePool")]
    [Parameter(ParameterSetName = "byVM")]
    [switch]$NoRecursion,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [Parameter(ParameterSetName = "byDatastore")]
    [Parameter(ParameterSetName = "byResourcePool")]
    [Parameter(ParameterSetName = "byVM")]
    [ValidateSet('*','Name','Id','PowerState','ConnectionState','IsStandalone','LicenseKey')]
    [string[]]$Properties = @('Name','Id','PowerState','ConnectionState','IsStandalone','LicenseKey')
)

Import-Module VMware.VimAutomation.Core

try{
    if($Properties -contains '*'){
        $Properties = @('*')
    }
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Server' = $Script:vmServer
                            'NoRecursion' = $NoRecursion
                            }                            
    
    if($PSCmdlet.ParameterSetName  -eq "byID"){
        $cmdArgs.Add('ID',$ID)        
    }
    elseif($PSCmdlet.ParameterSetName  -eq "byName"){
        if([System.String]::IsNullOrWhiteSpace($Name) -eq $false){
            $cmdArgs.Add('Name', $Name)
        }        
    }
    elseif($PSCmdlet.ParameterSetName  -eq "byDatastore"){
        $cmdArgs.Add('Datastore', $Datastore)
    }
    elseif($PSCmdlet.ParameterSetName  -eq "byVM"){
        $cmdArgs.Add('VM', $VM)
    }
    $result = Get-VMHost @cmdArgs | Select-Object $Properties

    if($SRXEnv) {
        $SRXEnv.ResultMessage = $result
    }
    else{
        Write-Output $result
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