#Requires -Version 5.0
#requires -Modules Microsoft.Graph.Authentication 

<#
    .SYNOPSIS        
        Finds Microsoft Graph permissions based on search criteria
        
    .DESCRIPTION          

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires Library script MS Graph\_LIB_\MGLibrary
        Requires Modules Microsoft.Graph.Authentication 

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/MS%20Graph/Authentication

    .PARAMETER Uri
        [sr-en] Uri
        [sr-de]
        
    .PARAMETER Command
        [sr-en] Command
        [sr-de]
        
    .PARAMETER Method
        [sr-en] Method
        [sr-de]
        
    .PARAMETER ApiVersion
        [sr-en] ApiVersion
        [sr-de]
#>

param( 
    [Parameter(Mandatory = $true,ParameterSetName = 'Uri')]
    [string]$Uri,
    [Parameter(Mandatory = $true,ParameterSetName = 'Command')]
    [string]$Command,
    [Parameter(ParameterSetName = 'Uri')]
    [ValidateSet('Get','Post','Put','Patch','Delete')]
    [string]$Method,
    [Parameter(ParameterSetName = 'All')]
    [Parameter(ParameterSetName = 'Uri')]
    [Parameter(ParameterSetName = 'Command')]
    [ValidateSet('v1.0','beta')]
    [string]$ApiVersion
)

Import-Module Microsoft.Graph.Authentication 

try{
    ConnectMSGraph 
    [hashtable]$cmdArgs = @{
        ErrorAction = 'Stop'
    }
    switch($PSCmdlet.ParameterSetName){
        'Uri'{
            $cmdArgs.Add('Uri',$Uri)
            if($PSBoundParameters.ContainsKey('Method') -eq $true){
                $cmdArgs.Add('Method',$Method)
            }
            break
        }
        'Command'{
            $cmdArgs.Add('Command',$Command)
            break
        }
        default{
            $cmdArgs.Add('InputObject','*')
        }
    }    
    if($PSBoundParameters.ContainsKey('ApiVersion') -eq $true){
        $cmdArgs.Add('ApiVersion',$ApiVersion)
    }
    $result = Find-MgGraphCommand @cmdArgs | Select-Object * | Sort-Object Command

    if($SRXEnv) {
        $SRXEnv.ResultMessage = $result
    }
    else{
        Write-Output $result
    }
}
catch{
    throw 
}
finally{
    DisconnectMSGraph
}