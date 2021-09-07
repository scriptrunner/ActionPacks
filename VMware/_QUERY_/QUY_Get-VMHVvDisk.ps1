#Requires -Version 5.0
#Requires -Modules VMware.VimAutomation.Storage

<#
.SYNOPSIS
    Retrieves VDisk objects

.DESCRIPTION

.NOTES
    This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
    The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
    The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
    © ScriptRunner Software GmbH

.COMPONENT
    Requires Module VMware.VimAutomation.Storage

.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/VMware/_QUERY_

.Parameter VIServer
    [sr-en] IP address or the DNS name of the vSphere server to which you want to connect
    [sr-de] IP Adresse oder Name des vSphere Servers

.Parameter VICredential
    [sr-en] PSCredential object that contains credentials for authenticating with the server
    [sr-de] Benutzerkonto um diese Aktion durchzuführen

.Parameter DatastoreName
    [sr-en] Datastore from which retrieve the VDisks
    [sr-de] Datastore der vDisks
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential,
    [string]$DatastoreName
)

Import-Module VMware.VimAutomation.Storage

try{
    [string[]]$Properties = @('Name','Id')
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Server' = $Script:vmServer
                            }     
                            
    if($PSBoundParameters.ContainsKey('DatastoreName') -eq $true){
        $cmdArgs.Add('Datastore', $DatastoreName)
    }   
    $disks = Get-VDisk @cmdArgs | Select-Object $Properties | Sort-Object Name
    
    foreach($itm in $disks){
        if($SRXEnv) {
            $null = $SRXEnv.ResultList.Add($itm.ID)
            $null = $SRXEnv.ResultList2.Add($itm.Name) # Display
        }
        else{
            Write-Output $item.Name
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