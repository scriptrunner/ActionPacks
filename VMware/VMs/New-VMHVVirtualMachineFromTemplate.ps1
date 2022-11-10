#Requires -Version 5.0
#Requires -Modules VMware.VimAutomation.Core

<#
    .SYNOPSIS
        Creates a new virtual machine with use a the virtual machine template

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
        https://github.com/scriptrunner/ActionPacks/tree/master/VMware/VMs

    .Parameter VIServer
        [sr-en] IP address or the DNS name of the vSphere server to which you want to connect
        [sr-de] IP-Adresse oder DNS des vSphere Servers

    .Parameter VICredential
        [sr-en] PSCredential object that contains credentials for authenticating with the server
        [sr-de] Anmeldedaten für die Authentifizierung beim Server

    .Parameter TemplateName
        [sr-en] Virtual machine template you want to use for the creation of the new virtual machine
        [sr-de] Vorlage zur Erstellung der virtuellen Maschine

    .Parameter VMName
        [sr-en] Name for the new virtual machine
        [sr-de] Name der virtuellen Maschine

    .Parameter HostName
        [sr-en] Name of the host on which you want to create the new virtual machine
        [sr-de] Host der virtuellen Maschine

    .Parameter DatastoreName
        [sr-en] Datastore where you want to place the new virtual machine
        [sr-de] Datastore der virtuellen Maschine

    .Parameter ClusterName
        [sr-en] Datastore cluster where you want to place the new virtual machine
        [sr-de] Cluster der virtuellen Maschine

    .Parameter Notes
        [sr-en] Description of the new virtual machine
        [sr-de] Beschreibung der virtuellen Maschine

    .Parameter DiskStorageFormat
        [sr-en] Storage format of the disks of the virtual machine
        [sr-de] Festplattenformat der virtuellen Maschine

    .Parameter OSCustomizationSpec
        [sr-en] Specifies a customization specification that is to be applied to the new virtual machine. 
        This works only in 32-bit mode 
        [sr-de] Benutzerdefinierte Einstellungen der neuen virtuellen Maschine
        Nur für 32Bit

    .Parameter Location
        [sr-en] Folder where you want to place the new virtual machine
        [sr-de] Ordner der virtuellen Maschine
        
    .Parameter DrsAutomationLevel
        [sr-en] DRS (Distributed Resource Scheduler) automation level
        [sr-de] DRS Automationsebene

    .Parameter HAIsolationResponse
        [sr-en] Virtual machine should be powered off if a host determines that it is isolated from the rest of the compute resource
        [sr-de] Virtuelle Maschine soll ausgeschaltet werden, falls sie isoliert ist

    .Parameter HARestartPriority
        [sr-en] Virtual machine HA restart priority
        [sr-de] HA Restartpriorität
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true,ParameterSetName = "onDatastore")]
    [Parameter(Mandatory = $true,ParameterSetName = "onCluster")]
    [string]$VIServer,
    [Parameter(Mandatory = $true,ParameterSetName = "onDatastore")]
    [Parameter(Mandatory = $true,ParameterSetName = "onCluster")]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true,ParameterSetName = "onDatastore")]
    [Parameter(Mandatory = $true,ParameterSetName = "onCluster")]
    [string]$TemplateName,
    [Parameter(Mandatory = $true,ParameterSetName = "onDatastore")]
    [Parameter(Mandatory = $true,ParameterSetName = "onCluster")]
    [string]$HostName,
    [Parameter(Mandatory = $true,ParameterSetName = "onDatastore")]
    [Parameter(Mandatory = $true,ParameterSetName = "onCluster")]
    [string]$VMName,
    [Parameter(Mandatory = $true,ParameterSetName = "onDatastore")]
    [string]$DatastoreName,      
    [Parameter(Mandatory = $true,ParameterSetName = "onCluster")]
    [string]$ClusterName,
    [Parameter(ParameterSetName = "onDatastore")]
    [Parameter(ParameterSetName = "onCluster")]        
    [string]$Notes,
    [Parameter(ParameterSetName = "onDatastore")]
    [Parameter(ParameterSetName = "onCluster")]
    [ValidateSet("Thin", "Thick","EagerZeroedThick")]
    [string]$DiskStorageFormat = "Thick",
    [Parameter(ParameterSetName = "onDatastore")]
    [Parameter(ParameterSetName = "onCluster")]
    [string]$OSCustomizationSpec,
    [Parameter(ParameterSetName = "onDatastore")]
    [Parameter(ParameterSetName = "onCluster")]
    [string]$Location,
    [Parameter(ParameterSetName = "onCluster")]
    [ValidateSet("FullyAutomated", "Manual", "PartiallyAutomated", "AsSpecifiedByCluster","Disabled")]
    [string]$DrsAutomationLevel,
    [Parameter(ParameterSetName = "onCluster")]
    [ValidateSet("AsSpecifiedByCluster", "PowerOff", "DoNothing")]
    [string]$HAIsolationResponse,
    [Parameter(ParameterSetName = "onCluster")]
    [ValidateSet("Disabled", "Low", "Medium", "High", "ClusterRestartPriority")]
    [string]$HARestartPriority
)

Import-Module VMware.VimAutomation.Core

try{
    [string[]]$Properties = @('Name','Id','NumCpu','CoresPerSocket','Notes','GuestId','MemoryGB','VMSwapfilePolicy','ProvisionedSpaceGB','Folder')
    if([System.String]::IsNullOrWhiteSpace($Notes) -eq $true){
        $Notes = " "
    }
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop

    if($PSCmdlet.ParameterSetName  -eq "onDatastore"){
        $Script:store = Get-Datastore -Server $Script:vmServer -Name $DatastoreName -ErrorAction Stop
    }
    else{
        $Script:store = Get-Cluster -Server $Script:vmServer -Name $ClusterName -ErrorAction Stop
    }
    $Script:vmHost = Get-VMHost -Server $Script:vmServer -Name $HostName -ErrorAction Stop
    $Script:template = Get-Template -Server $Script:vmServer -Name $TemplateName -ErrorAction Stop
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Server' = $Script:vmServer
                            'Name' = $VMName 
                            'VMHost' = $vmHost 
                            'Notes' = $Notes 
                            'Confirm' = $false
                            'Template' = $Script:template 
                            'DiskStorageFormat' = $DiskStorageFormat 
                            'Datastore'= $Script:store
                            }
    if([System.String]::IsNullOrEmpty($Location) -eq $false){
         $cmdArgs.Add('Location', $folder)
    }
    if($PSBoundParameters.ContainsKey('OSCustomizationSpec') -eq $true){
        $spec = Get-OSCustomizationSpec -Name $OSCustomizationSpec -Server $Script:vmServer
        $cmdArgs.Add('OSCustomizationSpec' ,$spec)
    }
    $Script:machine = New-VM @cmdArgs
    
    if($PSCmdlet.ParameterSetName  -eq "onCluster"){
        if($PSBoundParameters.ContainsKey('DrsAutomationLevel') -eq $true){
            $null = Set-VM -Server $Script:vmServer -VM  $Script:machine -DrsAutomationLevel $DrsAutomationLevel -Confirm:$False -ErrorAction Stop
        }
        if($PSBoundParameters.ContainsKey('HAIsolationResponse') -eq $true){
            $null = Set-VM -Server $Script:vmServer -VM  $Script:machine -HAIsolationResponse $HAIsolationResponse -Confirm:$False -ErrorAction Stop
        }
        if($PSBoundParameters.ContainsKey('HARestartPriority') -eq $true){
            $null = Set-VM -Server $Script:vmServer -VM  $Script:machine -HARestartPriority $HARestartPriority -Confirm:$False -ErrorAction Stop
        }
    }
    
    $result = Get-VM -Server $Script:vmServer -Name $VMName | Select-Object $Properties
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