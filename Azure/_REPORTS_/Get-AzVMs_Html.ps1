#Requires -Version 5.0
#Requires -Modules Az.Compute

<#
    .SYNOPSIS
        Generates a report with the properties of virtual machines
    
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
        https://github.com/scriptrunner/ActionPacks/blob/master/Azure/Compute  

    .Parameter Name        
        [sr-en] Specifies the name of the virtual machine to get
        [sr-de] Name der virtuellen Maschine

    .Parameter Location        
        [sr-en] Specifies a location for the virtual machines to list
        [sr-de] Location die die virtuelle Maschine enthält

    .Parameter ResourceGroupName
        [sr-en] Specifies the name of the resource group of the virtual machine
        Mandatory when parameter name is set!
        [sr-de] Name der resource group die die virtuelle Maschine enthält
        Mandatory, wenn der Parameter Name angegeben wird
        
    .Parameter Properties
        [sr-en] List of properties to expand. Use * for all properties
        [sr-de] Liste der zu anzuzeigenden Eigenschaften. Verwenden Sie * für alle Eigenschaften
#>

param( 
    [string]$Name,
    [string]$ResourceGroupName,
    [string]$Location,
    [ValidateSet('*','Name', 'Location', 'ResourceGroupName', 'Tags', 'VmId', 'StatusCode', 'ID')]
    [string[]]$Properties = @('Name', 'Location', 'ResourceGroupName', 'VmId', 'StatusCode', 'ID')
)

Import-Module Az

try{
    if($Properties -contains '*'){
        $Properties = @('*')
    }
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'}
    
    if([System.String]::IsNullOrWhiteSpace($Name) -eq $false){
        $cmdArgs.Add('Name',$Name)
        $cmdArgs.Add('ResourceGroupName',$ResourceGroupName)
    }
    if([System.String]::IsNullOrWhiteSpace($Location) -eq $false){
        $cmdArgs.Add('Location',$Location)
    }

    $ret = Get-AzVM @cmdArgs | Select-Object $Properties

    if($SRXEnv) {
        ConvertTo-ResultHtml -Result $ret
    }
    else{
        Write-Output $ret
    }
}
catch{
    throw
}
finally{
}