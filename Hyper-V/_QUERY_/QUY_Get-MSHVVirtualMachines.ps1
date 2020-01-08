#Requires -Version 4.0
#Requires -Modules Hyper-V

<#
    .SYNOPSIS 
    	Get the VMs on the host

	.DESCRIPTION

	.NOTES
		This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
		The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
		The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
		the use and the consequences of the use of this freely available script.
		PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
		© ScriptRunner Software GmbH

	.COMPONENT
		
	.LINK
		https://github.com/scriptrunner/ActionPacks/tree/master/Hyper-V/_QUERY_

    .Parameter NamePattern
    	VM names pattern to select.

    .Parameter State
    	Specific Microsoft.HyperV.PowerShell.VMState to filter for.

    .Parameter Heartbeat
		Specific Microsoft.HyperV.PowerShell.VMHeartbeatStatus to filter for.
		
	.Parameter HostName
        Specifies the name of the Hyper-V host

	.Parameter AccessAccount
        Specifies the user account that have permission to perform this action

#>

Param
(
    [string]$NamePattern,
	[ValidateSet('Off', 'Running', 'Saved', 'Paused')]
    $State,
	[ValidateSet('Disabled', 'NoContact', 'Error', 'LostCommunication', 'OkApplicationsUnknown', 'OkApplicationsHealthy', 'OkApplicationsCritical')]
	$Heartbeat,
    [string]$HostName,
    [PSCredential]$AccessAccount
)

Import-Module Hyper-V

try{
	if([System.String]::IsNullOrWhiteSpace($NamePattern)){
        $NamePattern = "*"
	}
	if([System.String]::IsNullOrWhiteSpace($HostName)){
        $HostName = "."
    }
	if($null -eq $AccessAccount){
        $Script:VMs = Get-VM -ComputerName $HostName -Name $NamePattern -ErrorAction Stop 
    }
    else {
        $Script:Cim = New-CimSession -ComputerName $HostName -Credential $AccessAccount
        $Script:VMs = Get-VM -CimSession $Script:Cim  -Name $NamePattern -ErrorAction Stop | Sort-Object VMName
    } 
	Write-Output ('' + $Script:VMs.Count + ' examined VMs...')
	foreach ($vm in $Script:VMs) {
		$vmname = $vm.VMName
		$vmstate = $vm.State
		$vmheartbeat = $vm.Heartbeat
		$use = $true
		if ($State -and ($State -ne $vmstate)) { $use = $false; }
		if ($Heartbeat -and ($Heartbeat -ne $vmheartbeat)) { $use = $false; }
		if ($use) {
			$key = $vm.VMName
			$display = "{0} | {1} - {2}" -f $vmstate, $vmname, $vm.Status
			if ($SRXEnv) {
				$null = $SRXEnv.ResultList.Add($key)
				$null = $SRXEnv.ResultList2.Add($display)
			}
			else {
				Write-Output "$($key) = $($display)"
			}
		}
		else {
			Write-Output "  Ignoring '$($vmname)': State=$($vmstate), Heartbeat=$($vmheartbeat)"
		}
	}
	if ($SRXEnv) {
		Write-Output "Returning $($SRXEnv.ResultList.Count) Hyper-V VMs."
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