#Requires -Version 5.0
#Requires -Modules Az.Compute

<#
    .SYNOPSIS
        Creates a virtual machine
    
    .DESCRIPTION  
        
    .NOTES
        This PowerShell script was originally developed for ScriptRunner and has been adapted for a non-ScriptRunner environment.

    .COMPONENT
        Requires Module Az.Compute

    .Parameter Name
        [sr-en] Specifies a name for the virtual machine
        [sr-de] Name der virtuellen Maschine

    .Parameter ResourceGroupName
        [sr-en] Specifies the name of a resource group
        [sr-de] Name der resource group die die virtuelle Maschine enthält

    .Parameter Location
        [sr-en] Specifies the location for the virtual machine
        [sr-de] Location der virtuellen Maschine

    .Parameter AdminCredential
        [sr-en] The administrator credentials for the VM
        [sr-de] Administratoranmeldeinformationen für die VM

    .Parameter DataDiskSizeInGb
        [sr-en] Specifies the sizes of data disks in GB
        [sr-de] Größe von Datenträgern in GB

    .Parameter EnableUltraSSD
        [sr-en] Use UltraSSD disks for the vm
        [sr-de] UltraSSD-Datenträger verwenden für die virtuelle Maschine

    .Parameter Image
        [sr-en] The friendly image name upon which the VM will be built
        [sr-de] Imagename, auf dem die VM erstellt wird

    .Parameter AllocationMethod
        [sr-en] The IP allocation method for the public IP which will be created for the VM
        [sr-de] IP-Zuweisungsmethode für die öffentliche IP-Adresse

    .Parameter SecurityGroupName
        [sr-en] The name of a new (or existing) network security group (NSG) for the created VM to use. 
        If not specified, a name will be generated
        [sr-de] Name einer neuen (oder vorhandenen) Netzwerksicherheitsgruppe (NSG) für die erstellte VM. 
        Wenn nicht angegeben, wird ein Name generiert

    .Parameter SubnetName
        [sr-en] The name of a new (or existing) subnet for the created VM to use. 
        If not specified, a name will be generated
        [sr-de] Name eines neuen (oder vorhandenen) Subnetzes
        Wenn nicht angegeben, wird ein Name generiert

    .Parameter VirtualNetworkName
        [sr-en] The name of a new (or existing) virtual network for the created VM to use. 
        If not specified, a name will be generated
        [sr-de] Name eines neuen (oder vorhandenen) virtuellen Netzwerks
        Wenn nicht angegeben, wird ein Name generiert

    .Parameter Size
        [sr-en] The Virtual Machine Size
        [sr-de] Größe der virtuellen Maschine
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$Name,
    [Parameter(Mandatory = $true)]
    [pscredential]$AdminCredential,
    [string]$ResourceGroupName,
    [int]$DataDiskSizeInGb,
    [switch]$EnableUltraSSD,
    [ValidateSet('Win2022AzureEditionCore','Win2019Datacenter','Win2016Datacenter','Win2012R2Datacenter','Win2012Datacenter','UbuntuLTS','CentOS','CoreOS','Debian','openSUSE-Leap','RHEL','SLES')]
    [string]$Image = "Win2019Datacenter",
    [ValidateSet('Static', 'Dynamic')]
    [string]$AllocationMethod,
    [string]$Location,
    [string]$SecurityGroupName,
    [string]$SubnetName,
    [string]$VirtualNetworkName,
    [string]$Size = 'Standard_DS1_v2'
)

Import-Module Az.Compute

try{
    [string[]]$Properties = @('Name','StatusCode','ResourceGroupName','Id','VmId','Location','ProvisioningState','DisplayHint')
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Confirm' = $false
                            'Credential' = $AdminCredential
                            'Name' = $Name
                            'Image' = $Image
                            'EnableUltraSSD' = $EnableUltraSSD}

    if([System.String]::IsNullOrWhiteSpace($ResourceGroupName) -eq $false){
        $cmdArgs.Add('ResourceGroupName',$ResourceGroupName)
    }
    if([System.String]::IsNullOrWhiteSpace($Location) -eq $false){
        $cmdArgs.Add('Location',$Location)
    }
    if([System.String]::IsNullOrWhiteSpace($SecurityGroupName) -eq $false){
        $cmdArgs.Add('SecurityGroupName',$SecurityGroupName)
    }
    if([System.String]::IsNullOrWhiteSpace($SubnetName) -eq $false){
        $cmdArgs.Add('SubnetName',$SubnetName)
    }
    if([System.String]::IsNullOrWhiteSpace($VirtualNetworkName) -eq $false){
        $cmdArgs.Add('VirtualNetworkName',$VirtualNetworkName)
    }
    if([System.String]::IsNullOrWhiteSpace($AllocationMethod) -eq $false){
        $cmdArgs.Add('AllocationMethod',$AllocationMethod)
    }
    if($PSBoundParameters.ContainsKey('Size') -eq $true){
        $cmdArgs.Add('Size',$Size)
    }
    if($DataDiskSizeInGb -gt 0){
        $cmdArgs.Add('DataDiskSizeInGb',$DataDiskSizeInGb)
    }
                            
    $ret = New-AzVM @cmdArgs | Select-Object $Properties
    Write-Output $ret
}
catch{
    throw
}
finally{
}