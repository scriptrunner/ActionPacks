#Requires -Version 4.0
#Requires -Modules Hyper-V

<#
    .SYNOPSIS
        Sets the integration services on a virtual machine
    
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

    .Parameter VMName
        Specifies the virtual machine to be configured

    .Parameter AccessAccount
        Specifies the user account that have permission to perform this action

    .Parameter OperatingSystemLanguage
        Language of the Hyper-V operating system. The configuration of the integration services is language-dependent

    .Parameter ShutDown
        Enables/disables the integration service "Operating system shutdown"

    .Parameter TimeSynchronization
        Enables/disables the integration service "Time synchronization"

    .Parameter DataExchange
        Enables/disables the integration service "Data Exchange"

    .Parameter Heartbeat
        Enables(/disables the integration service "Heartbeat"

    .Parameter Backup
        Enables/disables the integration service "Backup (volume checkpoint)"

    .Parameter GuestServices
        Enables/disables the integration service "Guest services"
#>

param(
    [Parameter(Mandatory = $true,ParameterSetName = "Win2K12R2 or Win8.x")]
    [string]$VMHostName,
    [Parameter(Mandatory = $true,ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(Mandatory = $true,ParameterSetName = "Newer Systems")]
    [string]$VMName,
    [Parameter(ParameterSetName = "Newer Systems")]
    [string]$HostName,
    [Parameter(ParameterSetName = "Newer Systems")]
    [PSCredential]$AccessAccount,
    [Parameter(ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(ParameterSetName = "Newer Systems")]
    [ValidateSet('English','German')]
    [string]$OperatingSystemLanguage = "English",
    [Parameter(ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(ParameterSetName = "Newer Systems")]
    [ValidateSet('Enable','Disable')]
    [string]$ShutDown = "Enable",
    [Parameter(ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(ParameterSetName = "Newer Systems")]
    [ValidateSet('Enable','Disable')]
    [string]$TimeSynchronization = "Enable",
    [Parameter(ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(ParameterSetName = "Newer Systems")]
    [ValidateSet('Enable','Disable')]
    [string]$DataExchange = "Enable",
    [Parameter(ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(ParameterSetName = "Newer Systems")]
    [ValidateSet('Enable','Disable')]
    [string]$Heartbeat = "Enable",
    [Parameter(ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(ParameterSetName = "Newer Systems")]
    [ValidateSet('Enable','Disable')]
    [string]$Backup = "Enable",
    [Parameter(ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(ParameterSetName = "Newer Systems")]
    [ValidateSet('Enable','Disable')]
    [string]$GuestServices = "Disable"
)

Import-Module Hyper-V

try {
    $Script:setEnable = @()
    $Script:setDisable = @()
    function SetCommands(){
        $sd="Shutdown"
        $time="Time Synchronization"
        $data="Key-Value Pair Exchange"
        $beat = "Heartbeat"
        $vss = "VSS"
        $guest = "Guest Service Interface"
        if($OperatingSystemLanguage -eq 'German'){
            $sd = "Herunterfahren"
            $time = "Zeitsynchronisierung"
            $data = "Austausch von Schlüsselwertepaaren"
            $beat = "Takt"
            $guest = "Gastdienstschnittstelle"
        }
        if($ShutDown -eq 'Enable'){
            $Script:setEnable += $sd
        }
        else{
            $Script:setDisable += $sd
        }
        if($TimeSynchronization -eq 'Enable'){
            $Script:setEnable += $time
        }
        else{
            $Script:setDisable += $time
        }
        if($DataExchange -eq 'Enable'){
            $Script:setEnable += $data
        }
        else{
            $Script:setDisable += $data
        }
        if($Heartbeat -eq 'Enable'){
            $Script:setEnable += $beat
        }
        else{
            $Script:setDisable += $beat
        }
        if($Backup -eq 'Enable'){
            $Script:setEnable += $vss
        }
        else{
            $Script:setDisable += $vss
        }
        if($GuestServices -eq 'Enable'){
            $Script:setEnable += $guest
        }
        else{
            $Script:setDisable += $guest
        }
    }
    if($PSCmdlet.ParameterSetName  -eq "Win2K12R2 or Win8.x"){
        $HostName=$VMHostName
    }    
    if([System.String]::IsNullOrWhiteSpace($HostName)){
        $HostName = "."
    }
    if($null -eq $AccessAccount){
        $Script:VM = Get-VM -ComputerName $HostName -ErrorAction Stop | Where-Object {$_.VMName -eq $VMName -or $_.VMID -eq $VMName}
    }
    else {
        $Script:Cim = New-CimSession -ComputerName $HostName -Credential $AccessAccount
        $Script:VM = Get-VM -CimSession $Script:Cim -ErrorAction Stop | Where-Object {$_.VMName -eq $VMName -or $_.VMID -eq $VMName}
    }        
    if($null -ne $Script:VM){
        SetCommands
        if($Script:setEnable.Length -gt 0){
            Enable-VMIntegrationService -VM $Script:VM -Name $Script:setEnable -ErrorAction Stop
        }
        if($Script:setDisable.Length -gt 0){
            Disable-VMIntegrationService -VM $Script:VM -Name $Script:setDisable -ErrorAction Stop
        }        
        $Script:output = Get-VMIntegrationService -VM $Script:VM | Select-Object @('VMName', 'Name', 'Enabled')  | Format-Table
        if($SRXEnv) {
            $SRXEnv.ResultMessage = $Script:output
        }    
        else {
            Write-Output $Script:output
        }
    }
    else{
        if($SRXEnv) {
            $SRXEnv.ResultMessage = "Virtual machine $($VMName) not found"
        }    
        Throw "Virtual machine $($VMName) not found"
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