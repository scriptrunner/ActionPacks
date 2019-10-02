#Requires -Version 5.0
#Requires -Modules Az.Compute

<#
    .SYNOPSIS
        Creates a virtual machine
    
    .DESCRIPTION  
        
    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires Module Az
        Requires Library script AzureAzLibrary.ps1

    .LINK
        https://github.com/scriptrunner/ActionPacks/blob/master/Azure        

    .Parameter AzureCredential
        The PSCredential object provides the user ID and password for organizational ID credentials, or the application ID and secret for service principal credentials

    .Parameter Tenant
        Tenant name or ID

    .Parameter Name
        Specifies a name for the virtual machine        

    .Parameter ResourceGroupName
        Specifies the name of a resource group       

    .Parameter Location
        Specifies the location for the virtual machine

    .Parameter AdminCredential
        The administrator credentials for the VM

    .Parameter DataDiskSizeInGb
        Specifies the sizes of data disks in GB

    .Parameter EnableUltraSSD
        Use UltraSSD disks for the vm

    .Parameter Image
        The friendly image name upon which the VM will be built

    .Parameter AllocationMethod
        The IP allocation method for the public IP which will be created for the VM

    .Parameter SecurityGroupName
        The name of a new (or existing) network security group (NSG) for the created VM to use. 
        If not specified, a name will be generated

    .Parameter SubnetName
        The name of a new (or existing) subnet for the created VM to use. 
        If not specified, a name will be generated

    .Parameter VirtualNetworkName
        The name of a new (or existing) virtual network for the created VM to use. 
        If not specified, a name will be generated
#>

param( 
    [Parameter(Mandatory = $true)]
    [pscredential]$AzureCredential,
    [Parameter(Mandatory = $true)]
    [string]$Name,
    [Parameter(Mandatory = $true)]
    [pscredential]$AdminCredential,
    [string]$ResourceGroupName,
    [int]$DataDiskSizeInGb,
    [switch]$EnableUltraSSD,
    [ValidateSet('Win2016Datacenter', 'Win2012R2Datacenter', 'Win2012Datacenter', 'Win2008R2SP1', 'UbuntuLTS', 'CentOS', 'CoreOS', 'Debian', 'openSUSE-Leap', 'RHEL', 'SLES')]
    [string]$Image = "Win2016Datacenter",
    [ValidateSet('Static', 'Dynamic')]
    [string]$AllocationMethod,
    [string]$Location,
    [string]$SecurityGroupName,
    [string]$SubnetName,
    [string]$VirtualNetworkName,
    [string]$Tenant
)

Import-Module Az

try{
#    ConnectAzure -AzureCredential $AzureCredential -Tenant $Tenant

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
    if($DataDiskSizeInGb -gt 0){
        $cmdArgs.Add('DataDiskSizeInGb',$DataDiskSizeInGb)
    }
                            
    $ret = New-AzVM @cmdArgs

    if($SRXEnv) {
        $SRXEnv.ResultMessage = $ret 
    }
    else{
        Write-Output $ret
    }
}
catch{
    throw
}
finally{
 #   DisconnectAzure -Tenant $Tenant
}