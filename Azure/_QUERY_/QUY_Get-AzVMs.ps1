#Requires -Version 5.0
#Requires -Modules Az.Compute

<#
    .SYNOPSIS
        Gets the Azure virtual machines
    
    .DESCRIPTION  
        
    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires Module Az

    .LINK
        https://github.com/scriptrunner/ActionPacks/blob/master/Azure/_QUERY_
#>

param( 
)

Import-Module Az

$VerbosePreference = 'SilentlyContinue'

try{
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'}
    
    $vms = Get-AzVM @cmdArgs | Sort-Object Name

    foreach($vm in $vms){
        if($SRXEnv) {
            $null = $SRXEnv.ResultList.Add($vm.Name)
            $null = $SRXEnv.ResultList2.Add($vm.Name) # Display
        }
        else{
            Write-Output $grp.ResourceGroupName
        }
    }
}
catch{
    throw
}
finally{
}