#Requires -Version 5.0
#Requires -Modules VMware.VimAutomation.Core

<#
    .SYNOPSIS
        Assigns the tag to the entity

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
        https://github.com/scriptrunner/ActionPacks/tree/master/VMware/Tags

    .Parameter VIServer
        [sr-en] IP address or the DNS name of the vSphere server to which you want to connect
        [sr-de] IP Adresse oder Name des vSphere Servers

    .Parameter VICredential
        [sr-en] PSCredential object that contains credentials for authenticating with the server
        [sr-de] Benutzerkonto um diese Aktion durchzuführen

    .Parameter EntityName
        [sr-en] Object name
        [sr-de] Name des Objekts

    .Parameter EntityType
        [sr-en] Object type
        [sr-de] Typ des Objekts

    .Parameter Tag
        [sr-en] Name of the tag
        [sr-de] Name des Tags
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true)]
    [string]$Tag,
    [Parameter(Mandatory = $true)]
    [string]$EntityName,
    [ValidateSet('Cluster','Datacenter','Datastore','DatastoreCluster','Folder','ResourcePool','VApp','VM','VMHost')]
    [string]$EntityType = 'VM'
)

Import-Module VMware.VimAutomation.Core

try{
    [string[]]$Properties = @('Entity','Tag')    
    
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
    
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Server' = $Script:vmServer
    }
    $entity
    switch ($EntityType){
        'Cluster'{
            $entity = Get-Cluster @cmdArgs -Name $EntityName
        }
        'Datacenter'{
            $entity = Get-Datacenter @cmdArgs -Name $EntityName
        }
        'Datastore'{
            $entity = Get-Datastore @cmdArgs -Name $EntityName
        }
        'DatastoreCluster'{
            $entity = Get-DatastoreCluster @cmdArgs -Name $EntityName
        }
        'Folder'{
            $entity = Get-Folder @cmdArgs -Name $EntityName
        }
        'ResourcePool'{
            $entity = Get-ResourcePool @cmdArgs -Name $EntityName
        }
        'VApp'{
            $entity = Get-VApp @cmdArgs -Name $EntityName
        }
        'VM'{
            $entity = Get-VM @cmdArgs -Name $EntityName
        }
        'VMHost'{
            $entity = Get-VMHost @cmdArgs -Name $EntityName
        }
    }
    $objTag = Get-Tag @cmdArgs -Name $Tag
    $cmdArgs.Add('Tag', $objTag)
    $cmdArgs.Add('Entity', $entity)

    $result = New-TagAssignment @cmdArgs -Confirm:$false | Select-Object $Properties
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