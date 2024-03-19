#Requires -Version 5.0
#Requires -Modules SimplySQL

<#
.SYNOPSIS
    Lists all SqlConnections

.DESCRIPTION

.NOTES
    This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
    The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
    The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
    © ScriptRunner Software GmbH

.COMPONENT
    Requires Module SimplySQL

.LINK
    https://github.com/scriptrunner/ActionPacks/blob/master/DBSystems/_QUERY_
#>

[CmdLetBinding()]
Param(
   
)

Import-Module SimplySQL

try{
    $cons = Show-SqlConnection -All -ErrorAction Stop | Sort-Object ConnectionName

    foreach($itm in  $cons){
        if($SRXEnv) {            
            $null = $SRXEnv.ResultList.Add($itm.ConnectionName) # Value
            $null = $SRXEnv.ResultList2.Add("$($itm.ConnectionName) State: ($($itm.ConnectionState))") # DisplayValue            
        }
        else{
            Write-Output "$($itm.ConnectionName) State: ($($itm.ConnectionState))"
        }
    }
}
catch{
    throw
}
finally{
}