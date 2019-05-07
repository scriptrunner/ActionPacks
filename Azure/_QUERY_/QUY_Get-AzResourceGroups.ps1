#Requires -Version 5.0
#Requires -Modules Az.Resources

<#
    .SYNOPSIS
        Gets resource groups
    
    .DESCRIPTION  
        
    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, AppSphere AG assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of AppSphere AG.
        © AppSphere AG

    .COMPONENT
        Requires Module Az

    .LINK
        https://github.com/scriptrunner/ActionPacks/blob/master/Azure        

    .Parameter AzureCredential
        The PSCredential object provides the user ID and password for organizational ID credentials, or the application ID and secret for service principal credentials

    .Parameter Tenant
        Tenant name or ID
#>

param( 
    [Parameter(Mandatory = $true)]
    [pscredential]$AzureCredential,
    [string]$Tenant,
    [switch]$GetIDs
)

Import-Module Az

$VerbosePreference = 'SilentlyContinue'

try{
 <#   if([System.String]::IsNullOrWhiteSpace($Tenant) -eq $true){
        $null = Connect-AzAccount -Credential $AzureCredential -Force -Confirm:$false -ErrorAction Stop
    }
    else{
        $null = Connect-AzAccount -Credential $AzureCredential -Tenant $Tenant -Force -Confirm:$false -ErrorAction Stop
    }

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'}
  #>  
    $result = Get-AzResourceGroup @cmdArgs | Sort-Object ResourceGroupName

    foreach($grp in $result){
        if($SRXEnv) {
            $key
            if($GetIDs -eq $true){
                $SRXEnv.ResultList.Add($grp.ResourceId)
            }
            else{
                $SRXEnv.ResultList.Add($grp.ResourceGroupName)
            }
            $SRXEnv.ResultList2.Add($grp.ResourceGroupName) # Display
        }
        else{
            Write-Output $grp.ResourceGroupName
        }
    }
   # Disconnect-AzAccount -Confirm:$false -ErrorAction Stop
}
catch{
    throw
}
finally{
    
}