#Requires -Version 4.0
#Requires -Modules Hyper-V

<#
    .SYNOPSIS
        Enables or disables the advanced session mode on the Hyper-V host
    
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

    .Parameter Action
        Enables/disables the advanced session mode
#>

param(
    [Parameter(Mandatory = $true,ParameterSetName = "Win2K12R2 or Win8.x")]
    [string]$VMHostName,
    [Parameter(ParameterSetName = "Newer Systems")]
    [string]$HostName,
    [Parameter(ParameterSetName = "Newer Systems")]
    [PSCredential]$AccessAccount,
    [Parameter(ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(ParameterSetName = "Newer Systems")]
    [ValidateSet('Enable','Disable')]
    [string]$Action = "Enable"
)

Import-Module Hyper-V

try {
    if($PSCmdlet.ParameterSetName  -eq "Win2K12R2 or Win8.x"){
        $HostName = $VMHostName
    }   
    if([System.String]::IsNullOrWhiteSpace($HostName)){
        $HostName = "."
    }    
    [string[]]$Properties = @('Name','EnableEnhancedSessionMode','MemoryCapacity','LogicalProcessorCount','MacAddressMinimum','MacAddressMaximum')
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'}
    [hashtable]$getArgs = @{'ErrorAction' = 'Stop'}
    if($null -eq $AccessAccount){
        $cmdArgs.Add('ComputerName',$HostName)
        $getArgs.Add('ComputerName',$HostName)
    }
    else {
        $Script:Cim = New-CimSession -ComputerName $HostName -Credential $AccessAccount
        $cmdArgs.Add('CimSession',$Script:Cim)
        $getArgs.Add('CimSession',$Script:Cim)
    } 
    $cmdArgs.Add('EnableEnhancedSessionMode', ($Action -eq 'Enable'))

    Set-VMHost @cmdArgs
    $output = Get-VMHost @getArgs | Select-Object $Properties
             
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