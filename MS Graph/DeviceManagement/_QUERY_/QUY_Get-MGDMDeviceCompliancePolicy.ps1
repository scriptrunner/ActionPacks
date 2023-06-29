#Requires -Version 5.0
#requires -Modules Microsoft.Graph.DeviceManagement 

<#
    .SYNOPSIS        
        Returns Compliance Policies from Device Management

    .DESCRIPTION          

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires Modules Microsoft.Graph.DeviceManagement 

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/MS%20Graph/DeviceManagement/_QUERY_
#>

param( 
)

Import-Module Microsoft.Graph.DeviceManagement 

try{
    [hashtable]$cmdArgs = @{ErrorAction = 'Stop'
                            'All' = $null
    }
    $result = Get-MgDeviceManagementDeviceCompliancePolicy @cmdArgs | Sort-Object DisplayName

    foreach($itm in $result){
        if($SRXEnv){
            $null = $SRXEnv.ResultList.Add($itm.Id) # value
            $null = $SRXEnv.ResultList2.Add($itm.DisplayName) # display
        }
        else{
            Write-Output $itm.DisplayName
        }
    }
}
catch{
    throw 
}
finally{
}