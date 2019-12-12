#Requires -Version 4.0
#Requires -Modules Hyper-V

<#
    .SYNOPSIS
        Creates a new virtual switch on the Hyper-V host
    
    .DESCRIPTION  
        Use "Win2K12R2 or Win8.x" for execution on Windows Server 2012 R2 or on Windows 8.1,
        when execute on Windows Server 2016 / Windows 10 or newer, use "Newer Systems"

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires Module Hyper-V

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/Hyper-V/Host
    
    .Parameter VMHostName
        Specifies the name of the Hyper-V host

    .Parameter SwitchName
        Specifies the name or the unique identifier of the virtual switch to be retrieved

    .Parameter NetAdapterName
        Specifies the name of the network adapter to be bound to the external switch to be created

    .Parameter HostName
        Specifies the name of the Hyper-V host

    .Parameter AccessAccount
        Specifies the user account that have permission to perform this action

    .Parameter SwitchType
        Specifies the type of the switch to be created. On create an External virtual switch, specify the NetAdapterName parameter

    .Parameter AllowManagementOS
        Specifies whether the parent partition (i.e. the management operating system) is to have access to the physical NIC bound to the virtual switch to be created

    .Parameter EnableIov
        Specifies that IO virtualization is to be enabled on the virtual switch to be created

    .Parameter Notes
        Specifies a note to be associated with the switch to be created
#>

param(
    [Parameter(Mandatory = $true,ParameterSetName = "Win2K12R2 or Win8.x")]
    [string]$VMHostName,
    [Parameter(Mandatory = $true,ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(Mandatory = $true,ParameterSetName = "Newer Systems")]    
    [string]$SwitchName,
    [Parameter(ParameterSetName = "Newer Systems")]
    [string]$HostName,
    [Parameter(ParameterSetName = "Newer Systems")]
    [PSCredential]$AccessAccount,    
    [Parameter(ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(ParameterSetName = "Newer Systems")]
    [string]$NetAdapterName,
    [Parameter(ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(ParameterSetName = "Newer Systems")]
    [ValidateSet('External','Internal','Private')]
    [string]$SwitchType = 'External',
    [Parameter(ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(ParameterSetName = "Newer Systems")]
    [bool]$AllowManagementOS = $true,
    [Parameter(ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(ParameterSetName = "Newer Systems")]
    [bool]$EnableIov = $false,
    [Parameter(ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(ParameterSetName = "Newer Systems")]
    [string]$Notes
)

Import-Module Hyper-V

try {
    [string[]]$Properties = @('Name','ID','Notes','SwitchType','AllowManagementOS','IovEnabled','IsDeleted')
    if($PSCmdlet.ParameterSetName  -eq "Win2K12R2 or Win8.x"){
        $HostName=$VMHostName
    }   
    if([System.String]::IsNullOrWhiteSpace($HostName)){
        $HostName = "."
    }  

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Name' = $SwitchName   
                            'Notes' = $Notes 
                            'EnableIov' = $EnableIov         
                            }
    [hashtable]$getArgs = @{'ErrorAction' = 'Stop'
                            'Name' = $SwitchName  
                            } 
    if($null -eq $AccessAccount){
        $cmdArgs.Add('ComputerName',$HostName)
        $getArgs.Add('ComputerName',$HostName)
    }
    else {
        $Script:Cim = New-CimSession -ComputerName $HostName -Credential $AccessAccount
        $cmdArgs.Add('CimSession',$Script:Cim)
        $getArgs.Add('CimSession',$Script:Cim)
    }  
    if($SwitchType -ne 'External'){
        $cmdArgs.Add('SwitchType',$SwitchType)
    }
    else {
        $cmdArgs.Add('NetAdapterName', $NetAdapterName)
        $cmdArgs.Add('AllowManagementOS', $AllowManagementOS)
    }
    $null = New-VMSwitch @cmdArgs        
    $output = Get-VMSwitch @getArgs | Select-Object $Properties
  
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $output
    }    
    else {
        Write-Output $output
    }
}
catch {
    throw
}
finally{
    if($null -ne $Script:Cim){
        Remove-CimSession $Script:Cim 
    }
}