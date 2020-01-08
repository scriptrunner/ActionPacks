#Requires -Version 4.0
# Requires -Modules VMware.PowerCLI

<#
.SYNOPSIS
    Retrieves information about the specified SCSI LUN disk

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
    Specifies hosts to retrieve the hard disks attached to them
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential,
    [string]$HostName
)

Import-Module VMware.PowerCLI

try{
    if([System.String]::IsNullOrWhiteSpace($HostName) -eq $true){
        $HostName = "*"
    }
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
    $disks = Get-VMHostDisk -Server $Script:vmServer -VMHost $HostName -ErrorAction Stop | Select-Object * | Sort-Object DeviceName      
        
    foreach($item in $disks){
        if($SRXEnv) {
            $null = $SRXEnv.ResultList.Add($item.Id.toString())
            $null = $SRXEnv.ResultList2.Add("TotalSectors: $($item.TotalSectors) - DeviceName: $($item.DeviceName)") # Display
        }
        else{
            Write-Output "TotalSectors: $($item.TotalSectors) - DeviceName: $($item.DeviceName)"
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