#Requires -Version 4.0

<#
    .SYNOPSIS
        Set a printer as default

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
        https://github.com/scriptrunner/ActionPacks/tree/master/O365/WinPrintManagement/Printers

    .Parameter PrinterName
        Full name of the printer
        
    .Parameter UseWmi
        Sets the printer via WMI as default, otherwise via .NET
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]  
    [string]$PrinterName,
    [switch]$UseWmi
)


try{    
    function ViaDotNet(){
        [System.Reflection.Assembly]::LoadWithPartialName('System.Printing')
        [System.Printing.EnumeratedPrintQueueTypes]$quTypes = @([System.Printing.EnumeratedPrintQueueTypes]::Connections,[System.Printing.EnumeratedPrintQueueTypes]::Local)
        [System.Printing.PrintServer]$prs = New-Object System.Printing.PrintServer
        [System.Printing.PrintQueueCollection]$col = $prs.GetPrintQueues($quTypes)
        [System.Printing.PrintQueue]$prQueue = $col | Where-Object {$_.FullName -eq $PrinterName}
        # set default printer
        try{
            if($null -ne $prQueue){
                [System.Printing.LocalPrintServer]$localPS = New-Object System.Printing.LocalPrintServer
                $localPS.DefaultPrintQueue = [System.Printing.PrintQueue]$prQueue
                $localPS.Commit()
                $localPS.Dispose()
                $prQueue.Dispose()
            }
            else{
                throw "Printer $($PrinterName) not found"
            }  
        }
        finally{
            $col.Dispose()
            $prs.Dispose()
        }
    }

    function ViaWMI(){
        $prObj = Get-CimInstance -Class Win32_Printer -Filter "Name='$($PrinterName)'"
        # set default printer
        if($null -ne $prQueue){
            Invoke-CimMethod -InputObject $prObj -MethodName SetDefaultPrinter
        }
        else{
            throw "Printer $($PrinterName) not found"
        }  
    }

    # call function
    if($UseWmi){
        ViaWMI
    }
    else{
        ViaDotNet
    }  
    
    if($SRXEnv) {
        $SRXEnv.ResultMessage = "Printer $($PrinterName) is set as default printer"
    } 
    else {
        Write-Output "Printer $($PrinterName) is set as default printer"
    }    
}
catch{
    throw
}