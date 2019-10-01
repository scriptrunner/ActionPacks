#Requires -Version 5.0
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
    .SYNOPSIS
       Adds a new SharePoint user or security group as GeoAdministrator to a multi-geo tenant 
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires Module Microsoft.Online.SharePoint.PowerShell
        ScriptRunner Version 4.2.x or higher

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/O365/SharePointOnline/Common

    .Parameter UserPrincipalName 
        User principal name

    .Parameter Group
        Name of the group
#>

param(        
    [Parameter(Mandatory=$true,ParameterSetName="User")]
    [string]$UserPrincipalName,
    [Parameter(ParameterSetName="Group")]
    [string]$Group
)

Import-Module Microsoft.Online.SharePoint.PowerShell

try{
    $Script:result = $null
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'}      
    
    If($PSCmdlet.ParameterSetName -eq 'User'){
        $Script:result = Add-SPOGeoAdministrator -UserPrincipalName $UserPrincipalName @cmdArgs | Select-Object *
    }
    else{       
        $Script:result = Add-SPOGeoAdministrator -GroupAlias $Group @cmdArgs | Select-Object *
    }

    if($SRXEnv) {
        $SRXEnv.ResultMessage = $Script:result
    }
    else {
        Write-Output $Script:result 
    }    
}
catch{
    throw
}
finally{
}