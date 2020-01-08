#Requires -Version 4.0
# Requires -Modules VMware.PowerCLI

<#
.SYNOPSIS
    Retrieves running or queued tasks

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
    https://github.com/scriptrunner/ActionPacks/tree/master/VMware/_QUERY_

.Parameter VIServer
    Specifies the IP address or the DNS name of the vSphere server to which you want to connect

.Parameter VICredential
    Specifies a PSCredential object that contains credentials for authenticating with the server
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential
)

Import-Module VMware.PowerCLI

try{
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
   
    $tasks = Get-Task -Server $Script:vmServer -ErrorAction Stop

    foreach($item in $tasks){
        if(($item.State -eq "Running") -or ($item.State -eq "Queued")){
            $name = ""
            switch ($item.objectid.split("-")[0].toLower()){
                "datacenter" {
                    $name = Get-Datacenter -Server $Script:vmServer -Id $item.objectid -ErrorAction Ignore | Select-Object -ExpandProperty Name | Sort-Object Name
                }
                "datastore" {
                    $name = Get-Datastore -Server $Script:vmServer -Id $item.objectid -ErrorAction Ignore | Select-Object -ExpandProperty Name | Sort-Object Name
                }
                "hostsystem" {
                    $name = Get-VMHost -Server $Script:vmServer -Id $item.objectid -ErrorAction Ignore | Select-Object -ExpandProperty Name | Sort-Object Name
                }
                "resourcepool" {
                    $name = Get-ResourcePool -Server $Script:vmServer -Id $item.objectid -ErrorAction Ignore | Select-Object -ExpandProperty Name | Sort-Object Name
                }
                "virtualmachine" {
                    $name = Get-VM -Server $Script:vmServer -Id $item.objectid -ErrorAction Ignore | Select-Object -ExpandProperty Name | Sort-Object Name
                }
            }
            if([System.String]::IsNullOrWhiteSpace($name) -eq $true){
                $name = $item.objectid
            }
            if($SRXEnv) {
                $null = $SRXEnv.ResultList.Add($item.ID.toString())
                $null = $SRXEnv.ResultList2.Add("$($name) - $($item.Description)") # Display
            }
            else{
                Write-Output "$($name) - $($item.Description)"
            }
        }
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