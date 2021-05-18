#Requires -Version 5.0
# Requires -Modules ActiveDirectory # check before execute the script

<#
    .SYNOPSIS
        Description of the script
    
    .DESCRIPTION  
        Versions or developer and so on

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Components needed to execute the script, e.g. Requires Module ActiveDirectory

    .LINK
        Links to the sources and so on
        
    .Parameter Para1
        Description of the parameters
#>

param( # parameter block
)

# Import the required modules, e.g. Import-Module ActiveDirectory

try{ #error handling
    
    if($SRXEnv) {
        $SRXEnv.ResultMessage = "My result"
    }
    else{
        Write-Output "My result"
    }
}
catch{
    throw # throws error for ScriptRunner
}
finally{
    # final todos, e.g. Disconnect server
}