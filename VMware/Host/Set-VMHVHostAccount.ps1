#Requires -Version 4.0
# Requires -Modules VMware.PowerCLI

<#
.SYNOPSIS
    Configures a host account

.DESCRIPTION

.NOTES
    This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
    The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
    The terms of use for ScriptRunner do not apply to this script. In particular, AppSphere AG assumes no liability for the function, 
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of AppSphere AG.
    © AppSphere AG

.COMPONENT
    Requires Module VMware.PowerCLI

.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/VMware/Host

.Parameter VIServer
    Specifies the IP address or the DNS name of the vSphere server to which you want to connect

.Parameter VICredential
    Specifies a PSCredential object that contains credentials for authenticating with the server

.Parameter Id
    Specifies an ID of the host user account you want to configure

.Parameter Password
    Specifies a new password of host user account you want to configure

.Parameter Description
    Provides a description of the specified account

.Parameter GrantShellAccess
    Indicates that the account is allowed to access the ESX shell
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true)]
    [string]$Id,
    [string]$Password,
    [string]$Description,
    [bool]$GrantShellAccess
)

Import-Module VMware.PowerCLI

try{   
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
    
    $Script:uAccount = Get-VMHostAccount -Server $Script:vmServer -Id $Id -ErrorAction Stop
    if($PSBoundParameters.ContainsKey('Password') -eq $true){
        $Script:uAccount = Set-VMHostAccount -UserAccount $Script:uAccount -Password $Password -Confirm:$false -ErrorAction Stop
    }if($PSBoundParameters.ContainsKey('Description') -eq $true){
        $Script:uAccount = Set-VMHostAccount -UserAccount $Script:uAccount -Description $Description -Confirm:$false -ErrorAction Stop
    }if($PSBoundParameters.ContainsKey('GrantShellAccess') -eq $true){
        $Script:uAccount = Set-VMHostAccount -UserAccount $Script:uAccount -GrantShellAccess $GrantShellAccess -Confirm:$false -ErrorAction Stop
    }
    $Script:Output = $Script:uAccount | Select-Object *

    if($SRXEnv) {
        $SRXEnv.ResultMessage = $Script:Output 
    }
    else{
        Write-Output $Script:Output
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