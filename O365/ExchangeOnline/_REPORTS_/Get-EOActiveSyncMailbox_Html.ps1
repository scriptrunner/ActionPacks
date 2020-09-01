#Requires -Version 4.0

<#
    .SYNOPSIS
       Generates a report with Active Sync settings
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH     

    .COMPONENT     
        Requires Library Script ReportLibrary from the Action Pack Reporting\_LIB_

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/O365/ExchangeOnline/_Reports_
#>

param(
    )

try{
    [string[]]$Properties = @('ActiveSyncEnabled','DisplayName','PrimarySmtpAddress')
    $res = Get-CASMailbox -ErrorAction Stop | Select-Object $Properties | Sort-Object DisplayName

    ConvertTo-ResultHtml -Result $res
}
catch{
    throw
}
finally{
 
}