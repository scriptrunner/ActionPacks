#Requires -Version 5.1

<#
.SYNOPSIS
    Gets the list of available time zones

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

#>

[CmdLetBinding()]
Param(
)

try{
    if($SRXEnv) {
        $SRXEnv.ResultList =@()
        $SRXEnv.ResultList2 =@()
    }
    $Script:Zones = Get-TimeZone -ListAvailable -ErrorAction Stop | Select-Object ID,DisplayName | Sort-Object -Property DisplayName
    foreach($item in $Script:Zones)
    {
        if($SRXEnv) {
            $SRXEnv.ResultList += $item.ID
            $SRXEnv.ResultList2 += $item.DisplayName # Display
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