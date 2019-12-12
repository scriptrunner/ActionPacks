#Requires -Version 4.0
#Requires -Modules Hyper-V

<#
    .SYNOPSIS
        Modifies the replication settings  on the Hyper-V host
    
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
        Enables/disables the replication

    .Parameter AuthenticationType
        Specifies which authentication types the Replica server will use

    .Parameter KerberosAuthenticationPort
        Specifies the port that the HTTP listener uses on the Replica server host

    .Parameter CertificateAuthenticationPort
        Specifies the port on which the Replica server will receive replication data using certificate-based authentication

    .Parameter Certificate
        Specifies the certificate to use for mutual authentication of the replication data. 
        This parameter is required only when Certificate is specified as the type of authentication

    .Parameter DefaultStorageLocation
        Specifies the default location to store the virtual hard disk files when a Replica virtual machine is created. 
        You must specify this parameter when AllowedFromAnyServer is True

    .Parameter AllowedFromAnyServer
        Specifies whether to accept replication requests from any server
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
    [string]$Action = "Enable",
    [Parameter(ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(ParameterSetName = "Newer Systems")]
    [ValidateSet('Kerberos', 'Certificate', 'CertificateAndKerberos')]
    [string]$AuthenticationType = "Kerberos",
    [Parameter(ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(ParameterSetName = "Newer Systems")]
    [int]$KerberosAuthenticationPort = 80,
    [Parameter(ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(ParameterSetName = "Newer Systems")]
    [int]$CertificateAuthenticationPort = 443,
    [Parameter(ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(ParameterSetName = "Newer Systems")]
    [string]$Certificate,
    [Parameter(ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(ParameterSetName = "Newer Systems")]
    [string]$DefaultStorageLocation ,
    [Parameter(ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(ParameterSetName = "Newer Systems")]
    [bool]$AllowedFromAnyServer
)

Import-Module Hyper-V

try {
    [object[]]$Script:output = @()
    if($PSCmdlet.ParameterSetName  -eq "Win2K12R2 or Win8.x"){
        $HostName=$VMHostName
    }   
    if([System.String]::IsNullOrWhiteSpace($HostName)){
        $HostName = "."
    }    
    [string[]]$Properties = @('ReplicationEnabled','AllowedAuthenticationType','KerberosAuthenticationPort','CertificateAuthenticationPort','AllowAnyServer','ReplicationAllowedFromAnyServer','DefaultStorageLocation','StatusDescriptions')
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Force' = $null    
                            }
    if($null -eq $AccessAccount){
        $cmdArgs.Add('ComputerName',$HostName)
    }
    else {
        $Script:Cim = New-CimSession -ComputerName $HostName -Credential $AccessAccount
        $cmdArgs.Add('CimSession',$Script:Cim)
    } 
    
    if($Action -eq "Enable"){
        Set-VMReplicationServer @cmdArgs -ReplicationEnabled $true -AllowedAuthenticationType $AuthenticationType
    }
    else {
        Set-VMReplicationServer @cmdArgs -ReplicationEnabled $false
    }
    if($PSBoundParameters.ContainsKey('KerberosAuthenticationPort') -eq $true ){
        Set-VMReplicationServer @cmdArgs -KerberosAuthenticationPort $KerberosAuthenticationPort
    }
    if($PSBoundParameters.ContainsKey('CertificateAuthenticationPort') -eq $true ){
        Set-VMReplicationServer @cmdArgs -CertificateAuthenticationPort $CertificateAuthenticationPort
    }
    if($PSBoundParameters.ContainsKey('Certificate') -eq $true ){
        Set-VMReplicationServer @cmdArgs -CertificateThumbprint $Certificate
    }
    if($PSBoundParameters.ContainsKey('AllowedFromAnyServer') -eq $true ){
        Set-VMReplicationServer @cmdArgs -ReplicationAllowedFromAnyServer $AllowedFromAnyServer -DefaultStorageLocation $DefaultStorageLocation
    }
    elseif($PSBoundParameters.ContainsKey('DefaultStorageLocation') -eq $true ){
        Set-VMReplicationServer @cmdArgs -DefaultStorageLocation $DefaultStorageLocation
    }
    $cmdArgs.Remove('Force')
    $output = Get-VMReplicationServer @cmdArgs | Select-Object $Properties
             
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