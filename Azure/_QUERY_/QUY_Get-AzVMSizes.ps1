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

    .Parameter ResourceGroupName
        Specifies the name of the resource group of the virtual machine
#>

param( 
    [Parameter(Mandatory = $true)]
    [pscredential]$AzureCredential,
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]$VMName,
    [string]$Tenant
)

Import-Module Az

$VerbosePreference = 'SilentlyContinue'

try{
<#    if([System.String]::IsNullOrWhiteSpace($Tenant) -eq $true){
        $null = Connect-AzAccount -Credential $AzureCredential -Force -Confirm:$false -ErrorAction Stop
    }
    else{
        $null = Connect-AzAccount -Credential $AzureCredential -Tenant $Tenant -Force -Confirm:$false -ErrorAction Stop
    }    
#>
    $result = Get-AzVMSize -ResourceGroupName $ResourceGroupName -VMName $VMName -ErrorAction Stop

    foreach($item in $result){
        if($SRXEnv) {
            $SRXEnv.ResultList.Add($item.Name)
            $SRXEnv.ResultList2.Add($item.Name) # Display
        }
        else{
            Write-Output $item.Name
        }
    }

  #  Disconnect-AzAccount -Confirm:$false -ErrorAction Stop
}
catch{
    throw
}
finally{
    
}