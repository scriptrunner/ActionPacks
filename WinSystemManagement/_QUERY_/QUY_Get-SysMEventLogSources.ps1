#Requires -Version 4.0

<#
.SYNOPSIS
    Retrieves the sources from an event log

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
    https://github.com/scriptrunner/ActionPacks/tree/master/WinClientManagement/_QUERY_

.Parameter LogName
    Specifies the event log

.Parameter ComputerName
    Specifies remote computer, the default is the local computer
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$LogName,
    [string]$ComputerName
)

try{
    if([System.String]::IsNullOrWhiteSpace($ComputerName)){
        $ComputerName = "."
    }   
    if($SRXEnv) {
        $SRXEnv.ResultList =@()
        $SRXEnv.ResultList2 =@()
    }
    $Script:Sources = Get-EventLog -ComputerName $ComputerName -LogName $LogName  -ErrorAction Stop | Select-Object Source -Unique
    foreach($item in $Script:Sources)
    {
        if($SRXEnv) {
            $SRXEnv.ResultList += $item.Source
            $SRXEnv.ResultList2 += $item.Source # Display
        }
        else{
            Write-Output $item.Source
        }
    }
}
catch{
    throw
}
finally{
}