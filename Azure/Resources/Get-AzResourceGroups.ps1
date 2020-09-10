#Requires -Version 5.0
#Requires -Modules Az.Resources

<#
    .SYNOPSIS
        Gets resource groups
    
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
        [sr-en] Specifies the name of the resource group to get. 
        This parameter supports wildcards at the beginning and/or the end of the string 
        [sr-de] Name der Resource Group. 
        Dieser Parameter unterstützt Wildcards am Anfang und/oder am Ende des Namens  
        
    .Parameter Tag
        [sr-en] The tag to filter resource groups 
        [sr-de] Tag, nach dem Resource Groups gefiltert werden sollen

    .Parameter Identifier
        [sr-en] Specifies the ID of the resource group to get. Wildcard characters are not permitted
        [sr-de] ID der Resource Group

    .Parameter Location
        [sr-en] Specifies the location of the resource group to get
        [sr-de] Location der Resource Group
#>

param( 
    [Parameter(ParameterSetName="byName")]
    [string]$Name,
    [Parameter(Mandatory = $true,ParameterSetName="byID")]
    [string]$Identifier,
    [Parameter(ParameterSetName="byName")]
    [Parameter(ParameterSetName="byID")]
    [string]$Tag,
    [Parameter(ParameterSetName="byName")]
    [Parameter(ParameterSetName="byID")]
    [string]$Location
)

Import-Module Az

try{
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'}
    
    if([System.String]::IsNullOrWhiteSpace($Name) -eq $false){
        $cmdArgs.Add('Name',$Name)
    }
    if($PSCmdlet.ParameterSetName -eq "byID"){
        $cmdArgs.Add('ID',$Identifier)
    }
    if([System.String]::IsNullOrWhiteSpace($Tag) -eq $false){
        $cmdArgs.Add('Tag',$Tag)
    }
    if([System.String]::IsNullOrWhiteSpace($Location) -eq $false){
        $cmdArgs.Add('Location',$Location)
    }

    $ret = Get-AzResourceGroup @cmdArgs

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