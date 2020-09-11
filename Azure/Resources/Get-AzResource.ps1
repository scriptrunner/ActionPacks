#Requires -Version 5.0
#Requires -Modules Az.Resources

<#
    .SYNOPSIS
        Gets resources
    
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
        https://github.com/scriptrunner/ActionPacks/blob/master/Azure/Resources 

    .Parameter Name
        [sr-en] Specifies the name of the resources to get. 
        This parameter supports wildcards at the beginning and/or the end of the string 
        [sr-de] Name der Ressource 
        Dieser Parameter unterstützt Wildcards am Anfang und/oder am Ende des Namens  

    .Parameter ResourceGroupName
        [sr-en] The resource group the resource(s) that is retrieved belongs in
        [sr-de] Ressourcen Gruppe die die Ressourcen enthält

    .Parameter ExpandProperties
        [sr-en] When specified, expands the properties of the resource
        [sr-de] Erweitert die Eigenschaften der Ressource

    .Parameter ResourceType
        [sr-en] The resource type of the resource(s)
        [sr-de] Typ der Ressourcen
        
    .Parameter Tag
        [sr-en] Gets resources that have the specified Azure tag
        [sr-de] Ressourcen die dieses Tag enthalten

    .Parameter Properties
        [sr-en] List of properties to expand. Use * for all properties
        [sr-de] Liste der zu anzuzeigenden Eigenschaften. Verwenden Sie * für alle Eigenschaften
#>

param( 
    [string]$Name,
    [string]$ResourceGroupName,
    [string]$ResourceType,
    [string]$Tag,
    [switch]$ExpandProperties ,
    [ValidateSet('*','Name','ResourceGroupName','ResourceType','Location','ResourceId','Tags')]
    [string[]]$Properties = @('Name','ResourceGroupName','ResourceType','Location')
)

Import-Module Az

try{
    if($Properties -contains '*'){
        $Properties = @('*')
    }
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'ExpandProperties' = $ExpandProperties
    }
    
    if([System.String]::IsNullOrWhiteSpace($Name) -eq $false){
        $cmdArgs.Add('Name',$Name)
    }
    if([System.String]::IsNullOrWhiteSpace($ResourceGroupName) -eq $false){
        $cmdArgs.Add('ResourceGroupName',$ResourceGroupName)
    }
    if([System.String]::IsNullOrWhiteSpace($Tag) -eq $false){
        $cmdArgs.Add('Tag',$Tag)
    }

    $ret = Get-AzResource @cmdArgs | Sort-Object Name | Select-Object $Properties

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
}