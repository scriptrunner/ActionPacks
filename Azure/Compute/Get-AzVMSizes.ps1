#Requires -Version 5.0
#Requires -Modules Az.Compute

<#
    .SYNOPSIS
        Gets available virtual machine sizes
    
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
        Requires Library script AzureAzLibrary.ps1

    .LINK
        https://github.com/scriptrunner/ActionPacks/blob/master/Azure        

    .Parameter AzureCredential
        The PSCredential object provides the user ID and password for organizational ID credentials, or the application ID and secret for service principal credentials

    .Parameter Tenant
        Tenant name or ID

    .Parameter VMName
        Specifies the name of the virtual machine that this cmdlet gets the available virtual machine sizes for resizing

    .Parameter Location
        Specifies the location for which this cmdlet gets the available virtual machine sizes

    .Parameter ResourceGroupName
        Specifies the name of the resource group of the virtual machine
#>

param( 
    [Parameter(Mandatory = $true,ParameterSetName = "Location")]
    [Parameter(Mandatory = $true,ParameterSetName = "Resource group")]
    [pscredential]$AzureCredential,
    [Parameter(Mandatory = $true,ParameterSetName = "Resource group")]
    [string]$ResourceGroupName,
    [Parameter(Mandatory = $true,ParameterSetName = "Resource group")]
    [string]$VMName,
    [Parameter(Mandatory = $true,ParameterSetName = "Location")]
    [string]$Location,
    [Parameter(ParameterSetName = "Location")]
    [Parameter(ParameterSetName = "Resource group")]
    [string]$Tenant
)

Import-Module Az

try{
 #   ConnectAzure -AzureCredential $AzureCredential -Tenant $Tenant
    
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'}
    
    if($PSCmdlet.ParameterSetName -eq "Resource group"){
        $cmdArgs.Add('ResourceGroupName',$ResourceGroupName)
        if([System.String]::IsNullOrWhiteSpace($VMName) -eq $false){
            $cmdArgs.Add('VMName',$VMName)
        }
    }
    else{
        $cmdArgs.Add('Location',$Location)
    }

    $ret = Get-AzVMSize @cmdArgs | Select-Object *

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
  #  DisconnectAzure -Tenant $Tenant
}