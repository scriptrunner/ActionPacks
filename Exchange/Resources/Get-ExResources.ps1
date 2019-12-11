#Requires -Version 4.0

<#
    .SYNOPSIS
        Connect to Microsoft Exchange Server and gets the resources
    
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
    $res = Get-Mailbox -SortBy DisplayName | Select-Object * | Where-Object -Property IsResource -EQ $true
    if($null -ne $res){
        if($SRXEnv) {
            $SRXEnv.ResultMessage = $res
        } 
        else{
            Write-Output $res 
        }
    }
    else{
        if($SRXEnv) {
            $SRXEnv.ResultMessage = "No resources found"
        } 
        else{
            Write-Output  "No resources found"
        }

    }
}
catch{
    throw
}
finally{
    
}