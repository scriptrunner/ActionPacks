#Requires -Version 5.0
#Requires -Modules SimplySQL

<#
.SYNOPSIS
    Lists all SqlConnections

.DESCRIPTION

.NOTES
    This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
    The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
    The terms of use for ScriptRunner do not apply to this script. In particular, AppSphere AG assumes no liability for the function, 
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of AppSphere AG.
    © AppSphere AG

.COMPONENT
    Requires Module SimplySQL

.LINK
    https://github.com/scriptrunner/ActionPacks/blob/master/DatabaseManagementSystem/_QUERY_
#>

[CmdLetBinding()]
Param(
   
)

Import-Module SimplySQL

try{
    if($SRXEnv) {
        $SRXEnv.ResultList =@()
        $SRXEnv.ResultList2 =@()
    }
    $cons = Show-SqlConnection -All -ErrorAction Stop

    foreach($itm in  $cons){
        if($SRXEnv) {            
            $SRXEnv.ResultList += $itm.ConnectionName # Value
            $SRXEnv.ResultList2 += "$($itm.ConnectionName) State: ($($itm.ConnectionState))" # DisplayValue            
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