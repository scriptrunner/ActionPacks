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
        The terms of use for ScriptRunner do not apply to this script. In particular, AppSphere AG assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of AppSphere AG.
        © AppSphere AG

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
    [string]$Properties="ReplicationEnabled,AllowedAuthenticationType,KerberosAuthenticationPort,CertificateAuthenticationPort,AllowAnyServer,ReplicationAllowedFromAnyServer,DefaultStorageLocation,StatusDescriptions"
    if($null -eq $AccessAccount){        
        if($Action -eq "Enable"){
            Set-VMReplicationServer -ComputerName $HostName -ReplicationEnabled $true -AllowedAuthenticationType $AuthenticationType -ErrorAction Stop
        }
        else {
            Set-VMReplicationServer -ComputerName $HostName -ReplicationEnabled $false -ErrorAction Stop
        }
        if($PSBoundParameters.ContainsKey('KerberosAuthenticationPort') -eq $true ){
            Set-VMReplicationServer -ComputerName $HostName -KerberosAuthenticationPort $KerberosAuthenticationPort -Force -ErrorAction Stop
        }
        if($PSBoundParameters.ContainsKey('CertificateAuthenticationPort') -eq $true ){
            Set-VMReplicationServer -ComputerName $HostName -CertificateAuthenticationPort $CertificateAuthenticationPort -Force -ErrorAction Stop
        }
        if($PSBoundParameters.ContainsKey('Certificate') -eq $true ){
            Set-VMReplicationServer -ComputerName $HostName -CertificateThumbprint $Certificate -Force -ErrorAction Stop
        }
        if($PSBoundParameters.ContainsKey('AllowedFromAnyServer') -eq $true ){
            Set-VMReplicationServer -ComputerName $HostName -ReplicationAllowedFromAnyServer $AllowedFromAnyServer -DefaultStorageLocation $DefaultStorageLocation -Force -ErrorAction Stop
        }
        elseif($PSBoundParameters.ContainsKey('DefaultStorageLocation') -eq $true ){
            Set-VMReplicationServer -ComputerName $HostName -DefaultStorageLocation $DefaultStorageLocation -Force -ErrorAction Stop
        }
        $Script:output = Get-VMReplicationServer -ComputerName $HostName -ErrorAction Stop | Select-Object $Properties.Split(',')
    }
    else {
        $Script:Cim = New-CimSession -ComputerName $HostName -Credential $AccessAccount
        if($Action -eq "Enable"){
            Set-VMReplicationServer -CimSession $Script:Cim -ReplicationEnabled $true -AllowedAuthenticationType $AuthenticationType -Force #-ErrorAction Stop
        }
        else {
            Set-VMReplicationServer -CimSession $Script:Cim -ReplicationEnabled $false -Force -ErrorAction Stop
        }
        if($PSBoundParameters.ContainsKey('KerberosAuthenticationPort') -eq $true ){
            Set-VMReplicationServer -CimSession $Script:Cim -KerberosAuthenticationPort $KerberosAuthenticationPort -Force -ErrorAction Stop
        }
        if($PSBoundParameters.ContainsKey('CertificateAuthenticationPort') -eq $true ){
            Set-VMReplicationServer -CimSession $Script:Cim -CertificateAuthenticationPort $CertificateAuthenticationPort -Force -ErrorAction Stop
        }
        if($PSBoundParameters.ContainsKey('Certificate') -eq $true ){
            Set-VMReplicationServer -CimSession $Script:Cim -CertificateThumbprint $Certificate -Force -ErrorAction Stop
        }
        if($PSBoundParameters.ContainsKey('AllowedFromAnyServer') -eq $true ){
            Set-VMReplicationServer -CimSession $Script:Cim -ReplicationAllowedFromAnyServer $AllowedFromAnyServer -DefaultStorageLocation $DefaultStorageLocation -Force -ErrorAction Stop
        }
        elseif($PSBoundParameters.ContainsKey('DefaultStorageLocation') -eq $true ){
            Set-VMReplicationServer -CimSession $Script:Cim -DefaultStorageLocation $DefaultStorageLocation -Force -ErrorAction Stop
        }
        $Script:output = Get-VMReplicationServer -CimSession $Script:Cim -ErrorAction Stop | Select-Object $Properties.Split(',')
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