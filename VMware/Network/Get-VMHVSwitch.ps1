#Requires -Version 5.0
# Requires -Modules VMware.VimAutomation.Vds

<#
    .SYNOPSIS
        Retrieves vSphere distributed switches

    .DESCRIPTION

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires Module VMware.VimAutomation.Vds

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/VMware/Network

    .Parameter VIServer
        [sr-en] IP address or the DNS name of the vSphere server to which you want to connect
        [sr-de] IP Adresse oder DNS des vSphere Servers

    .Parameter VICredential
        [sr-en] PSCredential object that contains credentials for authenticating with the server
        [sr-de] Benutzerkonto für die Ausführung

    .Parameter SwitchName
        [sr-en] Name of the vSphere distributed switch that you want to retrieve, is the parameter empty all distributed switches retrieved
        [sr-de] Name der Switch
        
    .Parameter SwitchID
        [sr-en] ID of the vSphere distributed switch that you want to retrieve
        [sr-de] ID der Switch
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true,ParameterSetName = "ByName")]
    [Parameter(Mandatory = $true,ParameterSetName = "ByID")]
    [string]$VIServer,
    [Parameter(Mandatory = $true,ParameterSetName = "ByName")]
    [Parameter(Mandatory = $true,ParameterSetName = "ByID")]
    [pscredential]$VICredential,
    [Parameter(ParameterSetName = "ByName")]
    [string]$SwitchName,
    [Parameter(Mandatory = $true,ParameterSetName = "ByID")]    
    [string]$SwitchID
)

Import-Module VMware.VimAutomation.Vds

try{
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
    
    if($PSCmdlet.ParameterSetName  -eq "ByName"){
        if([System.String]::IsNullOrWhiteSpace($SwitchName) -eq $true){
            $Script:Output = Get-VDSwitch -Server $Script:vmServer -ErrorAction Stop | Select-Object *
        }
        else {
            $Script:Output = Get-VDSwitch -Server $Script:vmServer -Name $SwitchName -ErrorAction Stop | Select-Object *            
        }
    }   
    else {
        $Script:Output = Get-VDSwitch -Server $Script:vmServer -Id $SwitchID -ErrorAction Stop | Select-Object *
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