#Requires -Version 4.0
#Requires -Modules PrintManagement

<#
.SYNOPSIS
    Get local printers from the specified computer

.DESCRIPTION
    
.NOTES
    This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
    The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
    The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
    © ScriptRunner Software GmbH

.COMPONENT
    Requires Module PrintManagement

.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/WinPrintManagement/Printers

.Parameter ComputerName
    Specifies the name of the computer from which to retrieve the printer information
    
.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.

.Parameter IncludeTcpIpPortProperties
    Specifies get the TCP/IP port address and number
#>

[CmdLetBinding()]
Param(
    [string]$ComputerName,
    [PSCredential]$AccessAccount,
    [switch]$IncludeTcpIpPortProperties
)

Import-Module PrintManagement

$Script:Cim = $null
try{
    [string[]]$Properties = @('Name','DriverName','PortName','Shared','Sharename','Comment','Location','Datatype','PrintProcessor','RenderingMode')
    if([System.string]::IsNullOrWhiteSpace($ComputerName)){
        $ComputerName = [System.Net.DNS]::GetHostByName('').HostName
    }          
    if($null -eq $AccessAccount){
        $Script:Cim = New-CimSession -ComputerName $ComputerName -ErrorAction Stop
    }
    else {
        $Script:Cim = New-CimSession -ComputerName $ComputerName -Credential $AccessAccount -ErrorAction Stop
    }

    $printers = Get-Printer -Full -CimSession $Script:Cim -ComputerName $ComputerName -ErrorAction Stop | Where-Object {$_.Type -eq 'Local'} `
                                    | Select-Object $Properties | Sort-Object Name
    $Script:Csv=@()
    $Script:Msg=@()
    $Script:Port
    foreach($item in $printers)
    {
        $tmp= ([ordered] @{            
            ComputerName= $ComputerName
            PrinterName = $item.Name
            PrinterDriver= $item.DriverName
            PortAddress= $item.PortName
            PortNumber = ''
            Shared = $item.Shared
            DifferentShareName = ''
            Comment = $item.Comment
            Location = $item.Location
            Datatype = $item.DataType
            PrintProcessor = $item.PrintProcessor
            RenderingMode = $item.RenderingMode
        }   )
        if($item.Shared -and $item.Sharename -ne $item.Name){
            $tmp.DifferentShareName = $item.Sharename
        }
        if($IncludeTcpIpPortProperties){
            try{
                $Script:Port = Get-PrinterPort -CimSession $Script:Cim -Name $item.PortName -ComputerName $ComputerName -ErrorAction SilentlyContinue
                if($null -ne $Script:Port.PrinterHostAddress){
                    $tmp.PortAddress =$Script:Port.PrinterHostAddress                
                    if($null -ne $Script:Port.PortNumber){
                        $tmp.PortNumber =$Script:Port.PortNumber
                    }                
                }
            }
            catch{
                $Script:Msg += "Error get printer port $($item.PortName) / $($_.Exception.Message)"
            }
        }
        $Script:Csv += New-Object PSObject -Property $tmp 
    }

    if($SRXEnv) {
        $SRXEnv.ResultMessage = $Script:Csv
    }
    else{
        Write-Output $Script:Csv
    }
}
catch{
    throw
}
finally{
    if($null -ne $Script:Cim){
        Remove-CimSession $Script:Cim 
    }
}