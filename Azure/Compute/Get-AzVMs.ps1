#Requires -Version 5.0
#Requires -Modules Az.Compute

<#
    .SYNOPSIS
        Gets the properties of a virtual machine
    
    .DESCRIPTION  
        
    .NOTES
        This PowerShell script was originally developed for ScriptRunner and has been adapted for a non-ScriptRunner environment.

    .COMPONENT
        Requires Module Az.Compute

    .Parameter Name        
        [sr-en] Specifies the name of the virtual machine to get
        [sr-de] Name der virtuellen Maschine

    .Parameter Location        
        [sr-en] Specifies a location for the virtual machines to list
        [sr-de] Location die die virtuelle Maschine enthält

    .Parameter ResourceGroupName
        [sr-en] Specifies the name of the resource group of the virtual machine
        [sr-de] Name der resource group die die virtuelle Maschine enthält
        
    .Parameter Properties
        [sr-en] List of properties to expand. Use * for all properties
        [sr-de] Liste der zu anzuzeigenden Eigenschaften. Verwenden Sie * für alle Eigenschaften
#>

param( 
    [Parameter(Mandatory = $true,ParameterSetName = 'ResourceGroup')]
    [string]$Name,
    [Parameter(Mandatory = $true,ParameterSetName = 'ResourceGroup')]
    [string]$ResourceGroupName,
    [Parameter(Mandatory = $true,ParameterSetName = 'Location')]
    [string]$Location,
    [Parameter(ParameterSetName = 'All')]
    [Parameter(ParameterSetName = 'Location')]
    [Parameter(ParameterSetName = 'ResourceGroup')]
    [ValidateSet('*','Name', 'Location', 'ResourceGroupName', 'Tags', 'VmId', 'StatusCode', 'ID')]
    [string[]]$Properties = @('Name', 'Location', 'ResourceGroupName', 'Tags', 'VmId', 'StatusCode', 'ID')
)

Import-Module Az.Compute

try{
    if($Properties -contains '*'){
        $Properties = @('*')
    }
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'}
    
    if($PSCmdlet.ParameterSetName -eq 'ResourceGroup'){
        $cmdArgs.Add('Name',$Name)
        $cmdArgs.Add('ResourceGroupName',$ResourceGroupName)
    }
    if($PSCmdlet.ParameterSetName -eq 'Location'){
        $cmdArgs.Add('Location',$Location)
    }

    $ret = Get-AzVM @cmdArgs | Select-Object $Properties

    Write-Output $ret
}
catch{
    throw
}
finally{
}