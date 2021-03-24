#Requires -Version 5.0

<#
    .SYNOPSIS
        Removes tag to object associations or deletes tags from the site altogether
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires the library script CitrixLibrary.ps1
        Requires PSSnapIn Citrix*

    .LINK
        https://github.com/scriptrunner/ActionPacks/blob/master/Citrix/Administration
        
    .Parameter SiteServer
        [sr-en] Specifies the address of a XenDesktop controller. 
        This can be provided as a host name or an IP address
        [sr-de] Name oder IP Adresse des XenDesktop Controllers

    .Parameter Name
        [sr-en] Tag name
        [sr-de] Name des Tags

    .Parameter TagName
        [sr-en] Tag name
        [sr-de] Name des Tags

    .Parameter AllApplications	
        [sr-en] Remove the specified tag from all applications
        [sr-de] Tag von allen Anwendungen entfernen

    .Parameter AllApplicationGroups	
        [sr-en] Remove the specified tag from all application groups
        [sr-de] Tag von allen Anwendungsgruppen entfernen

    .Parameter AllDesktops	
        [sr-en] Remove the specified tag from all desktops
        [sr-de] Tag von allen Desktops entfernen

    .Parameter AllDesktopGroups	
        [sr-en] Remove the specified tag from all desktop groups
        [sr-de] Tag von allen Desktop-Gruppen entfernen

    .Parameter AllMachines	
        [sr-en] Remove the specified tag from all machines
        [sr-de] Tag von allen Maschinen entfernen

    .Parameter AllObjects	
        [sr-en] Remove the specified tag from all objects
        [sr-de] Tag von allen Objekten entfernen
#>

param(
    [Parameter(Mandatory = $true,ParameterSetName = 'Associations')]
    [string]$Name,
    [Parameter(Mandatory = $true,ParameterSetName = 'TagObject')]
    [string]$TagName,
    [Parameter(ParameterSetName = 'Associations')]
    [switch]$AllApplications,
    [Parameter(ParameterSetName = 'Associations')]
    [switch]$AllApplicationGroups,
    [Parameter(ParameterSetName = 'Associations')]
    [switch]$AllDesktops,
    [Parameter(ParameterSetName = 'Associations')]
    [switch]$AllDesktopGroups,
    [Parameter(ParameterSetName = 'Associations')]
    [switch]$AllMachines,
    [Parameter(ParameterSetName = 'Associations')]
    [switch]$AllObjects,
    [Parameter(ParameterSetName = 'Associations')]
    [Parameter(ParameterSetName = 'TagObject')]
    [string]$SiteServer
)                                                            

$LogID = $null
[bool]$success = $false
try{ 
    [string]$Script:LogText
    if($PSCMdlet.ParameterSetName -eq 'TagObject'){
        $Name = $TagName
        $Script:LogText = "Remove tag $($Name)"
    }
    else{
        $Script:LogText = "Remove tag associations $($Name)"
    }
    StartCitrixSessionAdv -ServerName ([ref]$SiteServer)
    StartLogging -ServerAddress $SiteServer -LogText $Script:LogText -LoggingID ([ref]$LogID)

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'AdminAddress' = $SiteServer
                            'LoggingID' = $LogID
                            }       
   
    if($PSCMdlet.ParameterSetName -eq 'Associations'){
        $tag = Get-BrokerTag -Name $Name -AdminAddress $SiteServer -ErrorAction Stop
        $cmdArgs.Add('Tags' , $tag)
        $cmdArgs.Add('AllApplications' , $AllApplications)
        $cmdArgs.Add('AllApplicationGroups' , $AllApplicationGroups)
        $cmdArgs.Add('AllDesktops', $AllDesktops)
        $cmdArgs.Add('AllDesktopGroups' , $AllDesktopGroups)
        $cmdArgs.Add('AllMachines' , $AllMachines)
        $cmdArgs.Add('AllObjects' , $AllObjects)
    }
    else{
        $cmdArgs.Add('Name' , $Name)
    }

    $ret = Remove-BrokerTag @cmdArgs | Select-Object *
    $success = $true
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
    StopLogging -LoggingID $LogID -ServerAddress $SiteServer -IsSuccessful $success
    CloseCitrixSession
}