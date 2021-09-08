#Requires -Version 5.0
#Requires -Modules VMware.VumAutomation

<#
    .SYNOPSIS
        Retrieves all available patches

    .DESCRIPTION

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires Module VMware.VumAutomation

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/VMware/Patches

    .Parameter VIServer
        [sr-en] IP address or the DNS name of the vSphere server to which you want to connect
        [sr-de] IP Adresse oder Name des vSphere Servers

    .Parameter VICredential
        [sr-en] PSCredential object that contains credentials for authenticating with the server
        [sr-de] Benutzerkonto um diese Aktion durchzuführen

    .Parameter SearchPhrase	
        [sr-en] Phrases that are contained in the Name, Description, Id, and Vendor properties of the patches you want to retrieve. 
        Use commas to separate multiple phrases
        [sr-de]	Begriffe, die in den Eigenschaften Name, Beschreibung, Id und Vendor enthalten sind, Komma getrennt. 
        
    .Parameter Id	
        [sr-en] ID of the patch
        [sr-de] ID des Patchs

    .Parameter After
        [sr-en] Only patches released after the date
        [sr-de] Patchs nach diesem Datum

    .Parameter Before
        [sr-en] Only patches released before the date
        [sr-de] Patchs vor diesem Datum

    .Parameter BundleType 
        [sr-en] Bundle type of the patches
        [sr-de] Bundle-Typ der Patchs

    .Parameter Category
        [sr-en] Categories of the patches
        [sr-de] Kategorie der Patchs

    .Parameter InstallationImpact
        [sr-en] Installation impact of the patches
        [sr-de] Installationsauswirkungen der Patchs
    
    .Parameter Severity	
        [sr-en] Severity of the patch
        [sr-de] Schweregrad des Patchs
        
    .Parameter Product
        [sr-en] Name of software product
        [sr-de] Name des Produkts

    .Parameter Vendor
        [sr-en] Vendor of the patch
        [sr-de] Hersteller des Patchs

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
    [int]$Id,
    [datetime]$After,
    [datetime]$Before,
    [ValidateSet('Patch','Rollup','Update','Extension','Upgrade')]
    [string]$BundleType,
    [ValidateSet('SecurityFix','BugFix','Enhancement','Other')]
    [string]$Category,
    [ValidateSet('HostdRestart','Reboot','MaintenanceMode','MaintenanceModeHostdRestart','MaintenanceModeInstall','MaintenanceModeUpdate','FaultToleranceCompatibiliy')]
    [string]$InstallationImpact,
    [string]$Product,
    [string]$SearchPhrase,
    [ValidateSet('NotApplicable','Low','Moderate','Important','Critical','HostGeneral','HostSecurity')]
    [string]$Severity,
    [string]$Vendor,
    [ValidateSet('*','Name','Id','Vendor','Language','Description','Product','ReleaseDate','LastUpdateTime','Severity','Category','TargetType','BundleType','IsRecalled','Uid')]
    [string[]]$Properties = @('Name','Id','Vendor','Language','Description','Product','ReleaseDate','LastUpdateTime')
)

Import-Module VMware.VumAutomation

try{
    if($Properties -contains '*'){
        $Properties = @('*')
    }
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
    
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Server' = $Script:vmServer
    }
    if($Id -gt 0){
        $cmdArgs.Add('Id', $Id)
    }
    if($PSBoundParameters.ContainsKey('BundleType') -eq $true){
        $cmdArgs.Add('BundleType', $BundleType)
    }      
    if($PSBoundParameters.ContainsKey('Category') -eq $true){
        $cmdArgs.Add('Category', $Category)
    }  
    if(($PSBoundParameters.ContainsKey('After') -eq $true) -and ($After.Year -gt 2020)){
        $cmdArgs.Add('After', $After)
    }      
    if(($PSBoundParameters.ContainsKey('Before') -eq $true) -and ($Before.Year -gt 2020)){
        $cmdArgs.Add('Before', $Before)
    }  
    if($PSBoundParameters.ContainsKey('InstallationImpact') -eq $true){
        $cmdArgs.Add('InstallationImpact', $InstallationImpact)
    }  
    if($PSBoundParameters.ContainsKey('Product') -eq $true){
        $cmdArgs.Add('Product', $Product)
    }  
    if($PSBoundParameters.ContainsKey('SearchPhrase') -eq $true){
        $cmdArgs.Add('SearchPhrase', $SearchPhrase)
    }  
    if($PSBoundParameters.ContainsKey('Severity') -eq $true){
        $cmdArgs.Add('Severity', $Severity)
    }        
    if($PSBoundParameters.ContainsKey('Vendor') -eq $true){
        $cmdArgs.Add('Vendor', $Vendor)
    }   

    $result = Get-Patch @cmdArgs | Select-Object $Properties
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