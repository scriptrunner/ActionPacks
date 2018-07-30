#Requires -Version 4.0

<#
.SYNOPSIS
    Gets all services on a computer

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
    https://github.com/scriptrunner/ActionPacks/tree/master/WinSystemManagement/_QUERY_

.Parameter ComputerName
    Gets the service running on the specified computer. The default is the local computer
#>

[CmdLetBinding()]
Param(
    [string]$ComputerName
)

try{
    $Script:output
    if([System.String]::IsNullOrWhiteSpace($ComputerName) -eq $true){
        $ComputerName = "."
    }    

    if($SRXEnv) {
        $SRXEnv.ResultList =@()
        $SRXEnv.ResultList2 =@()
    }    
    $Script:services = Get-Service -ComputerName $ComputerName -ErrorAction Stop `
                        | Select-Object Name,DisplayName | Sort-Object DisplayName
    foreach($item in $Script:services)
    {
        if($SRXEnv) {
            $SRXEnv.ResultList += $item.Name
            $SRXEnv.ResultList2 += $item.DisplayName
        }
        else{
            Write-Output $item.DisplayName
        }
    }
}
catch{
    throw
}
finally{
}