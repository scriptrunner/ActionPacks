#Requires -Version 5.0
#Requires -Modules Az.Compute

<#
    .SYNOPSIS
        Gets the properties of a virtual machine
    
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
        Requires Library script AzureAzLibrary.ps1

    .LINK
        https://github.com/scriptrunner/ActionPacks/blob/master/Azure        

    .Parameter AzureCredential
        The PSCredential object provides the user ID and password for organizational ID credentials, or the application ID and secret for service principal credentials

    .Parameter Tenant
        Tenant name or ID

    .Parameter Name
        Specifies the name of the virtual machine to get

    .Parameter Location
        Specifies a location for the virtual machines to list

    .Parameter ResourceGroupName
        Specifies the name of a resource group. Mandatory when parameter name is set!
        
    .Parameter Properties
        List of properties to expand, comma separated e.g. Name,Location. Use * for all properties
#>

param( 
    [Parameter(Mandatory = $true)]
    [pscredential]$AzureCredential,
    [string]$Name,
    [string]$ResourceGroupName,
    [string]$Location,
    [string]$Properties = "Name, Location, ResourceGroupName, Tags, VmId, StatusCode, ID",
    [string]$Tenant
)

Import-Module Az

try{
#    ConnectAzure -AzureCredential $AzureCredential -Tenant $Tenant
    
    if([System.String]::IsNullOrWhiteSpace($Properties)){
        $Properties = '*'
    }
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'}
    
    if([System.String]::IsNullOrWhiteSpace($Name) -eq $false){
        $cmdArgs.Add('Name',$Name)
        $cmdArgs.Add('ResourceGroupName',$ResourceGroupName)
    }
    if([System.String]::IsNullOrWhiteSpace($Location) -eq $false){
        $cmdArgs.Add('Location',$Location)
    }

    $ret = Get-AzVM @cmdArgs | Select-Object $Properties.Split(',')

    if($SRXEnv) {
        $SRXEnv.ResultMessage = $ret 
    }
    else{
        Write-Output $ret
    }
}
catch{
    throw
}
finally{
 #   DisconnectAzure -Tenant $Tenant
}