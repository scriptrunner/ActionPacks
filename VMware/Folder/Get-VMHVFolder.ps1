#Requires -Version 4.0
# Requires -Modules VMware.PowerCLI

<#
.SYNOPSIS
    Retrieves the folders available on a vCenter Server system

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
    https://github.com/scriptrunner/ActionPacks/tree/master/VMware/Folder

.Parameter VIServer
    Specifies the IP address or the DNS name of the vSphere server to which you want to connect

.Parameter VICredential
    Specifies a PSCredential object that contains credentials for authenticating with the server

.Parameter FolderName
    Specifies the name of the folder you want to retrieve, is the parameter empty all folders retrieved

.Parameter LocationName
    Specifies a container object where you want to retrieve the folder

.Parameter LocationType
    Specifies the type of the container object where you want to retrieve the folder

.Parameter NoRecursion
    Indicates that you want to disable the recursive behavior of the command
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential,
    [string]$FolderName,
    [string]$LocationName,
    [ValidateSet("All","VM", "HostAndCluster", "Datastore", "Network","Datacenter")]
    [string]$LocationType = "All",
    [switch]$NoRecursion
)

Import-Module VMware.PowerCLI

try{
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Server' = $Script:vmServer
                            }                            
    
    if([System.String]::IsNullOrWhiteSpace($FolderName) -eq $true){
        $FolderName = "*"
    }
    if([System.String]::IsNullOrWhiteSpace($LocationName) -eq $false){
        $Script:location = Get-Folder @cmdArgs -Name $LocationName
        if($null -eq $Script:location){
            throw "Location $($LocationName) not found"
        }
        $cmdArgs.Add('Location',$Script:location)        
    }
    $cmdArgs.Add('Name',$FolderName)
    $cmdArgs.Add('NoRecursion', $NoRecursion)
    if($LocationType -ne "All"){
        $cmdArgs.Add('Type', $LocationType)
    }
    $result = Get-Folder @cmdArgs | Select-Object *
    
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