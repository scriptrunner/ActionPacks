#Requires -Version 4.0
#Requires -Modules Hyper-V

<#
    .SYNOPSIS
        Imports a virtual machine from a file
    
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
        https://github.com/scriptrunner/ActionPacks/tree/master/Hyper-V/VMs

    .Parameter VMHostName
        Specifies the name of the Hyper-V host

    .Parameter HostName
        Specifies the name of the Hyper-V host

    .Parameter Path
        Specifies the path to the exported virtual machine to be imported

    .Parameter Copy
        Specifies that the imported virtual machine's files should be copied to the server's default locations, as opposed to registering the virtual machine in-place
    
    .Parameter VirtualMachinePath
        Specifies the path where the virtual machine configuration files are to be stored

    .Parameter GenerateNewId
        Specifies that the imported virtual machine should be copied and given a new unique identifier

    .Parameter Register
        Specifies that the imported virtual machine is to be registered in-place, as opposed to copying its files to the server's default locations

    .Parameter SnapshotFilePath
        Specifies the path for any snapshot files associated with the virtual machine

    .Parameter VhdDestinationPath
        Specifies the folder to which the virtual machine's VHD files are to be copied

    .Parameter AccessAccount
        Specifies the user account that have permission to perform this action
#>

param(
    [Parameter(Mandatory = $true,ParameterSetName = "Win2K12R2 or Win8.x")]
    [string]$VMHostName,
    [Parameter(Mandatory = $true,ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(Mandatory = $true,ParameterSetName = "Newer Systems")]
    [string]$Path,
    [Parameter(ParameterSetName = "Newer Systems")]
    [string]$HostName,
    [Parameter(ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(ParameterSetName = "Newer Systems")]
    [switch]$Copy,
    [Parameter(ParameterSetName = "Newer Systems")]
    [PSCredential]$AccessAccount,
    [Parameter(ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(ParameterSetName = "Newer Systems")]
    [string]$VirtualMachinePath,
    [Parameter(ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(ParameterSetName = "Newer Systems")]
    [switch]$GenerateNewId, 
    [Parameter(ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(ParameterSetName = "Newer Systems")]
    [switch]$Register,
    [Parameter(ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(ParameterSetName = "Newer Systems")]
    [string]$SnapshotFilePath,
    [Parameter(ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(ParameterSetName = "Newer Systems")]
    [string]$VhdDestinationPath      
)

Import-Module Hyper-V

try {
    if($PSCmdlet.ParameterSetName  -eq "Win2K12R2 or Win8.x"){
        $HostName=$VMHostName
    }    
    if([System.String]::IsNullOrWhiteSpace($HostName)){
        $HostName = "."
    }
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Path' = $Path 
                            }
    if($null -eq $AccessAccount){
        $cmdArgs.Add('ComputerName', $HostName)
    }
    else {
        $Script:Cim = New-CimSession -ComputerName $HostName -Credential $AccessAccount
        $cmdArgs.Add('CimSession', $Script:Cim)
    }

    if($Register -eq $true){
        Import-VM @cmdArgs -Register
    }
    else {
        $cmdArgs.Add('GenerateNewId', $GenerateNewId)
        if($PSBoundParameters.ContainsKey('SnapshotFilePath') -eq $true){
            $cmdArgs.Add('SnapshotFilePath', $SnapshotFilePath)
        } 
        if($PSBoundParameters.ContainsKey('VirtualMachinePath') -eq $true){
            $cmdArgs.Add('VirtualMachinePath', $VirtualMachinePath)
        } 
        if($PSBoundParameters.ContainsKey('VhdDestinationPath') -eq $true){
            $cmdArgs.Add('VhdDestinationPath', $VhdDestinationPath)
        }  
        Import-VM @cmdArgs        
    }        
       
    if($SRXEnv) {
        $SRXEnv.ResultMessage = "Virtual machine imported from $($Path)"
    }    
    else {
        Write-Output "Virtual machine imported from $($Path)"
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