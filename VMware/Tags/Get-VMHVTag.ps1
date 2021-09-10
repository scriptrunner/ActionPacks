#Requires -Version 5.0
#Requires -Modules VMware.VimAutomation.Core

<#
    .SYNOPSIS
        Retrieves the tags 

    .DESCRIPTION

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires Module VMware.VimAutomation.Core

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/VMware/Tags

    .Parameter VIServer
        [sr-en] IP address or the DNS name of the vSphere server to which you want to connect
        [sr-de] IP Adresse oder Name des vSphere Servers

    .Parameter VICredential
        [sr-en] PSCredential object that contains credentials for authenticating with the server
        [sr-de] Benutzerkonto um diese Aktion durchzuführen

    .Parameter Name
        [sr-en] Name of the tag
        [sr-de] Name des Tags

    .Parameter Category
        [sr-en] Name of the tag category
        [sr-de] Name der Tag Kategorie

    .Parameter Properties
        [sr-en] List of properties to expand. Use * for all properties
        [sr-de] Liste der zu anzuzeigenden Eigenschaften. Verwenden Sie * für alle Eigenschaften
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential,
    [string]$Name,
    [string]$Category,
    [ValidateSet('*','Name','Description','Category','Id','Uid')]
    [string[]]$Properties = @('Name','Description','Category','Id')
)

Import-Module VMware.VimAutomation.Core

try{
    if($Properties -contains '*'){
        $Properties = @('*')
    }
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
    
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Server' = $Script:vmServer
    }
    if($PSBoundParameters.ContainsKey('Name') -eq $true){
        $cmdArgs.Add('Name', $Name)
    }
    if($PSBoundParameters.ContainsKey('Category') -eq $true){
        $cat = Get-TagCategory @cmdArgs -Name $Category
        $cmdArgs.Add('Category', $cat)
    }        

    $result = Get-Tag @cmdArgs | Select-Object $Properties
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $result
    }
    else{
        Write-Output $result
    }
}
catch{
    throw
}
finally{    
    if($null -ne $Script:vmServer){
        Disconnect-VIServer -Server $Script:vmServer -Force -Confirm:$false
    }
}