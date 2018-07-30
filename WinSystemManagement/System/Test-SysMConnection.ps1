#Requires -Version 4.0

<#
.SYNOPSIS
    Sends ICMP echo request packets ("pings") to one or more computers

.DESCRIPTION

.NOTES
    This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
    The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
    The terms of use for ScriptRunner do not apply to this script. In particular, AppSphere AG assumes no liability for the function, 
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of AppSphere AG.
    © AppSphere AG

.COMPONENT

.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/WinSystemManagement/System

.Parameter ComputerNames
    Specifies the computers to ping. Type the computer names or type IP addresses in IPv4 or IPv6 format. Use the comma to separate the names

.Parameter Count
    Specifies the number of echo requests to send

.Parameter DcomAuthentication
    Specifies the authentication level that this cmdlet uses with WMI

.Parameter Delay
    Specifies the interval between pings, in seconds
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$ComputerNames,
    [int32]$Count = 4,
    [ValidateSet("Default","None","Connect","Call","Packet","PacketIntegrity","PacketPrivacy","Unchanged")]
    [string]$DcomAuthentication = "Packet",
    [int32]$Delay = 2
)

try{
    $test = Get-Host | Select-Object -ExpandProperty Version
    if($test.major -lt 5  ){
        $output = Test-Connection -ComputerName $ComputerNames.Split(',') -Count $Count -Delay $Delay -Authentication $DcomAuthentication
    }
    elseif($test.major -eq 5  ){
        if($test.Minor -lt 1){
            $output = Test-Connection -ComputerName $ComputerNames.Split(',') -Count $Count -Delay $Delay -Authentication $DcomAuthentication
        }
        else {
            $output = Test-Connection -ComputerName $ComputerNames.Split(',') -Count $Count -Delay $Delay -DcomAuthentication $DcomAuthentication        
        }
    }
    else {
        $output = Test-Connection -ComputerName $ComputerNames.Split(',') -Count $Count -Delay $Delay -DcomAuthentication $DcomAuthentication        
    }
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $output
    }
    else{
        Write-Output $output
    }
}
catch{
    throw
}
finally{
}