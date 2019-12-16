#Requires -Version 4.0
# Requires -Modules VMware.PowerCLI

<#
.SYNOPSIS
    Modifies the VMware PowerCLI configuration

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
    https://github.com/scriptrunner/ActionPacks/tree/master/VMware/PowerCLI

.Parameter Scope
    Specifies the scope of the setting that you want to modify
    
.Parameter InvalidCertificateAction
    Define the action to take when an attempted connection to a server fails due to a certificate error
    
.Parameter DisplayDeprecationWarnings
    Indicates whether you want to see warnings about deprecated elements

.Parameter DefaultVIServerMode
    Specifies the server connection mode. The new configuration takes effect immediately after you run the script

.Parameter WebOperationTimeoutSeconds
    Defines the timeout for Web operations

.Parameter ProxyPolicy
    Specifies whether VMware PowerCLI uses a system proxy server to connect to the vCenter Server system

.Parameter CEIPDataTransferProxyPolicy
    Specifies the proxy policy for the connection through which Customer Experience Improvement Program (CEIP) data is sent to VMware. 
    Changing this setting requires a restart of PowerCLI before it takes effect

.Parameter ParticipateInCEIP
    Specifies if PowerCLI should send anonymous usage information to VMware. For more information about the Customer Experience Improvement Program (CEIP), see the PowerCLI User's Guide
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [ValidateSet( "Session", "User","AllUsers")]
    [string]$Scope = "User",
    [ValidateSet("Fail","Ignore","Prompt","Unset","Warn")]
    [string]$InvalidCertificateAction,
    [ValidateSet("Multiple","Single")]
    [string]$DefaultVIServerMode,
    [bool]$DisplayDeprecationWarnings,
    [int32]$WebOperationTimeoutSeconds,
    [ValidateSet("UseSystemProxy","NoProxy")]
    [string]$ProxyPolicy,
    [bool]$ParticipateInCEIP,
    [ValidateSet("UseSystemProxy","NoProxy")]
    [string]$CEIPDataTransferProxyPolicy
)

Import-Module VMware.PowerCLI

try{
    $Script:Output
    if($WebOperationTimeoutSeconds -gt 0){
        $null = Set-PowerCLIConfiguration -WebOperationTimeoutSeconds $WebOperationTimeoutSeconds -Scope $Scope -Confirm:$false -ErrorAction Stop
    }
    if([System.String]::IsNullOrWhiteSpace($InvalidCertificateAction) -eq $false){
        $null = Set-PowerCLIConfiguration -InvalidCertificateAction $InvalidCertificateAction -Scope $Scope -Confirm:$false -ErrorAction Stop
    }
    if([System.String]::IsNullOrWhiteSpace($DefaultVIServerMode) -eq $false){
        $null = Set-PowerCLIConfiguration -DefaultVIServerMode $DefaultVIServerMode -Scope $Scope -Confirm:$false -ErrorAction Stop
    }
    if([System.String]::IsNullOrWhiteSpace($ProxyPolicy) -eq $false){
        $null = Set-PowerCLIConfiguration -ProxyPolicy $ProxyPolicy -Scope $Scope -Confirm:$false -ErrorAction Stop
    }
    if($PSBoundParameters.ContainsKey('DisplayDeprecationWarnings') -eq $true){
        $null = Set-PowerCLIConfiguration -DisplayDeprecationWarnings $DisplayDeprecationWarnings -Scope $Scope -Confirm:$false -ErrorAction Stop
    }    
    if($PSBoundParameters.ContainsKey('ParticipateInCEIP') -eq $true){
        $null = Set-PowerCLIConfiguration -ParticipateInCEIP $ParticipateInCEIP -Scope $Scope -Confirm:$false -ErrorAction Stop
    }
    if([System.String]::IsNullOrWhiteSpace($CEIPDataTransferProxyPolicy) -eq $false){
        $null = Set-PowerCLIConfiguration -CEIPDataTransferProxyPolicy $CEIPDataTransferProxyPolicy -Scope $Scope -Confirm:$false -ErrorAction Stop
    }
    $result = Get-PowerCLIConfiguration -Scope $Scope -ErrorAction Stop | Format-List
    
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
}