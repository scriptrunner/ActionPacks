<#
    .SYNOPSIS
        Connect to Microsoft Exchange Server and gets the Active Sync Policies
        Can also be used as ScriptRunner Query
        Requirements 
        ScriptRunner Version 4.x or higher
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, AppSphere AG assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of AppSphere AG.
        © AppSphere AG 
#>

param(
    )

try{
    $res = Get-ActiveSyncMailboxPolicy 
    if($null -ne $res){    
        if($SRXEnv) {
            $SRXEnv.ResultList=@()
            $res | Select-Object Name | Sort-Object Name -Unique | foreach-object{
                $SRXEnv.ResultList += $_.Name
            }
            $SRXEnv.ResultMessage = $res
        } 
        else{            
            Write-Output $res
        }
    }
    else{
        if($SRXEnv) {
            $SRXEnv.ResultMessage = "No Policies found"
        } 
        else{
            Write-Output  "No Policies found"
        }
    }
}
finally{
 
}