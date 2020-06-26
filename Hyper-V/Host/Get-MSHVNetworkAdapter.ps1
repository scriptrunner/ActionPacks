#Requires -Version 4.0
#Requires -Modules Hyper-V

<#
    .SYNOPSIS
        Gets the virtual network adapter
    
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

    .Parameter HostName
        Specifies the name of the Hyper-V host

    .Parameter AccessAccount
        Specifies the user account that have permission to perform this action

    .Parameter Properties
        List of properties to expand, comma separated e.g. Name,Description. Use * for all properties

    .Parameter AdapterName
        Specifies the name of the network adapter to be retrieved

    .Parameter SwitchName
        Specifies the name of the virtual switch from the network adapter

    .Parameter IncludeVlanProperties
        Specifies show the Vlan properties of the adapter
#>

param(
    [Parameter(Mandatory = $true,ParameterSetName = "Win2K12R2 or Win8.x")]
    [string]$VMHostName,
    [Parameter(Mandatory = $true,ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(Mandatory = $true,ParameterSetName = "Newer Systems")]
    [string]$AdapterName,
    [Parameter(ParameterSetName = "Newer Systems")]
    [string]$HostName,
    [Parameter(ParameterSetName = "Newer Systems")]
    [PSCredential]$AccessAccount,
    [Parameter(ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(ParameterSetName = "Newer Systems")]
    [ValidateSet('*','Name','SwitchName','IsManagementOs','MacAddress','AdapterID','Status','StatusDescription','IsExternalAdapter','IsDeleted')]
    [string[]]$Properties = @('Name','SwitchName','IsManagementOs','MacAddress','AdapterID','Status','StatusDescription','IsExternalAdapter','IsDeleted'),
    [Parameter(ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(ParameterSetName = "Newer Systems")]
    [string]$SwitchName,
    [Parameter(ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(ParameterSetName = "Newer Systems")]
    [switch]$IncludeVlanProperties
)

Import-Module Hyper-V

try {
    $Script:output=@()
    if($Properties -contains '*'){
        $Properties = @('*')
    }
    if($PSCmdlet.ParameterSetName  -eq "Win2K12R2 or Win8.x"){
        $HostName=$VMHostName
    }   
    if([System.String]::IsNullOrWhiteSpace($HostName)){
        $HostName = "."
    }        
    else{
        if($true -eq $IncludeVlanProperties){
            if(($Properties -ne '*') -and ($null -eq ($Properties | Where-Object {$_ -eq 'Name'}))){
                $Properties += "Name"
            }
            if(($Properties -ne '*') -and ($null -eq ($Properties | Where-Object {$_ -eq 'IsManagementOs'}))){
                $Properties += "IsManagementOs"
            }
        }
    }
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'ManagementOS' = $null
                            'Name' = $AdapterName
                            }
    if($null -eq $AccessAccount){
        $cmdArgs.Add('ComputerName',$HostName)
    }
    else {
        $Script:Cim = New-CimSession -ComputerName $HostName -Credential $AccessAccount
        $cmdArgs.Add('CimSession',$Script:Cim)
    }     
    if([System.String]::IsNullOrWhiteSpace($SwitchName) -eq $false){
        $cmdArgs.Add('SwitchName', $SwitchName)
    }
    $Script:adapter = Get-VMNetworkAdapter @cmdArgs | Select-Object $Properties
    if($null -ne $Script:adapter){
        $Script:output += $Script:adapter
        if($true -eq $IncludeVlanProperties){
            if($Script:adapter.IsManagementOs -eq $true){
                if($null -eq $AccessAccount){
                    $tmp = Get-VMNetworkAdapter -Name $AdapterName -ManagementOS
                }
                else {
                    $tmp = Get-VMNetworkAdapter -CimSession $Script:Cim -Name $AdapterName -ManagementOS
                }
                $Script:output += Get-VMNetworkAdapterVlan -VMNetworkAdapter $tmp | Select-Object * -ExcludeProperty "ParentAdapter"
            }
        }
    }
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $Script:output
    }    
    else {
        Write-Output $Script:output
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