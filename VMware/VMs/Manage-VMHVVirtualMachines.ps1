# Requires -Version 4.0
# Requires -Modules VMware.PowerCLI

<#
.SYNOPSIS
    Start, stop or restart VMWare virtual machines

.DESCRIPTION

.NOTES
    This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner.
    The customer or user is authorized to copy the script from the repository and use them in ScriptRunner.
    The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function,
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
    ©ScriptRunner Software GmbH

.COMPONENT
    Requires Module VMware.PowerCLI
    
.LINK

.Parameter Action
    Specifies the Action for the virtual machines

.Parameter VIServer
    Specifies the IP address or the DNS name of the vSphere server to which you want to connect

.Parameter VICredential
    Specifies a PSCredential object that contains credentials for authenticating with the server

.Parameter VirtualMachines
    Specifies the virtual machines to be start, stop, restart, suspend or shutdown
#>

param(
    [ValidateSet("Start", "Stop", "Restart", "Suspend", "Shutdown")]
    [string]$Action,
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true, HelpMessage = "ASRDisplay(NoAutoSelect)")]
    [string[]]$VirtualMachines
)

Import-Module VMware.PowerCLI

try {
    $vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop

    $cmdArgs = @{
        'Server'   = $vmServer
        'Confirm'  = $false
        'RunAsync' = $true
        'VM'       = ''
    }
    #DELETE 
    if ($vmServer) {
        if ($Action -eq "Start") {
            foreach ($item in $VirtualMachines) {
                try {
                    $cmdArgs.VM = $item
                    Start-VM @cmdArgs
                    Write-Output "Computer $($item) startet successfully"
                }
                catch {
                    Write-Output "A problem occured starting the VM $($item)"
                }
            }
        }
        if ($Action -eq "Stop") {
            foreach ($item in $VirtualMachines) {
                try {
                    $cmdArgs.VM = $item
                    Stop-VM @cmdArgs
                    Write-Output "Computer $($item) stopped successfully"
                }
                catch {
                    Write-Output "A problem occured stopping the VM $($item)"
                }
            }   
        }
        if ($Action -eq "Restart") {
            foreach ($item in $VirtualMachines) {
                try {
                    $cmdArgs.VM = $item
                    Restart-VM @cmdArgs
                    Write-Output "Computer $($item) restartet successfully"
                }
                catch {
                    Write-Output "A problem occured restarting the VM $($item)"
                }
            }
        }
        if ($Action -eq "Suspend") {
            foreach ($item in $VirtualMachines) {
                try {
                    $cmdArgs.VM = $item
                    Suspend-VM @cmdArgs
                    Write-Output "Computer $($item) suspended successfully"
                }
                catch {
                    Write-Output "A problem occured suspending the VM $($item)"
                }
            }
        }
        if ($Action -eq "Shutdown") {
            foreach ($item in $VirtualMachines) {
                try {
                    $cmdArgs.VM = $item
                    $cmdArgs.Remove("RunAsync")
                    Shutdown-VMGuest @cmdArgs
                    Write-Output "Computer $($item) shutdown successfully"
                }
                catch {
                    Write-Output "A problem occured shutting down the VM $($item)"
                }
            }
        }
    }
    else {
        Write-Output "Connection to VI Server not established"
    }
}
catch {
    throw "Something went wrong"
}
finally{
    Disconnect-VIServer -Server $vmServer
}

