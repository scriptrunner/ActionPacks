#Requires -Version 5.0

<#
    .SYNOPSIS
        Description of the query script
    
    .DESCRIPTION  
        

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
    $result = Get-ADUser # e.g. read Active Directory Users
    foreach($itm in $result){ # fill result lists
        if($null -ne $SRXEnv) {            
            $null = $SRXEnv.ResultList.Add($itm.DistinguishedName) # Value
            $null = $SRXEnv.ResultList2.Add($itm.DisplayName) # DisplayValue            
        }
        else{
            Write-Output $itm.DisplayName 
        }
    }
}
catch{
    throw # throws error for ScriptRunner
}
finally{
    # final todos, e.g. Disconnect server
}