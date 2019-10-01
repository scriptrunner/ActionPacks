#Requires -Version 5.0
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
    .SYNOPSIS
        Enables or disables the current tenant's "SharePoint Online Client" service principal
    
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
        https://github.com/scriptrunner/ActionPacks/tree/master/O365/SharePointOnline/Tenant

    .Parameter Disable
        Disable the current tenant's "SharePoint Online Client" service principal
#>

param(            
    [Parameter(Mandatory = $true)]
    [bool]$Disable
)

Import-Module Microsoft.Online.SharePoint.PowerShell

try{
    $Script:result       
    if($Disable -eq $false){
        $Script:result = Enable-SPOTenantServicePrincipal -Confirm:$false -ErrorAction Stop  | Select-Object *
    }
    else{
        $Script:result = Disable-SPOTenantServicePrincipal -Confirm:$false -ErrorAction Stop  | Select-Object *
    }
      
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $result
    }
    else {
        Write-Output $result 
    }    
}
catch{
    throw
}
finally{
}