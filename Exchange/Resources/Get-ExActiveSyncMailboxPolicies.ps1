#Requires -Version 4.0

<#
    .SYNOPSIS
        Connect to Microsoft Exchange Server and gets the Active Sync Policies
        Can also be used as ScriptRunner Query
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH 

    .COMPONENT       
        ScriptRunner Version 4.x or higher

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/Exchange/Resources
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
catch{
    throw
}
finally{
 
}