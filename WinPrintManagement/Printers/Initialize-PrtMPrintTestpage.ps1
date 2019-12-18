#Requires -Version 4.0
#Requires -Modules PrintManagement

<#
.SYNOPSIS
    Initialize the print of a test page on the printer

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

.Parameter PrinterName
    Specifies the name of the printer

.Parameter ComputerName
    Specifies the computer name to the printer 
    
.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.
#>
   
[CmdLetBinding()]
Param(
    [Parameter(Mandatory=$true)]
    [string]$PrinterName,
    [string]$ComputerName,
    [PSCredential]$AccessAccount
)

$Script:Cim = $null
try{
    if([System.string]::IsNullOrWhiteSpace($ComputerName)){
        $ComputerName = [System.Net.DNS]::GetHostByName('').HostName
    }          
    if($null -eq $AccessAccount){
        $Script:Cim = New-CimSession -ComputerName $ComputerName -ErrorAction Stop
    }
    else {
        $Script:Cim = New-CimSession -ComputerName $ComputerName -Credential $AccessAccount -ErrorAction Stop
    }

    $cinst = Get-CimInstance -CimSession $Script:Cim -Query "SELECT * FROM WIN32_Printer WHERE Name ='$($PrinterName)'"
    $Script:Output = @()
    if($null -ne $cinst){
        $res=$Script:Cim.InvokeMethod($cinst,"PrintTestPage",$null)
        if($res.ReturnValue.Value -eq 0){
            $Script:Output +=  "Send print test page to Printer $($PrinterName) successfully"
        }
        else {
            $Script:Output +=  "Send print test page to Printer $($PrinterName) failed. Error $($res.ReturnValue.Value)"
        }
    }
    else{
        throw "Printer $($PrinterName) not found"
    }    
    
    if($SRXEnv) {
        $SRXEnv.ResultMessage =$Script:Output
    }
    else{
        Write-Output $Script:Output
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