#Requires -Version 5.0
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
    .SYNOPSIS
        Controls tenant-wide options and restrictions specific to syncing files
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires Module Microsoft.Online.SharePoint.PowerShell
        ScriptRunner Version 4.2.x or higher

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/O365/SharePointOnline/Tenant

    .Parameter ExcludedFileExtensions
        Blocks certain file types from syncing with the new sync client (OneDrive.exe)

    .Parameter BlockMacSync
        Block Mac sync clients

    .Parameter DomainGuids
        Sets the domain GUID to add to the safe recipient list, comma separated

    .Parameter Enable
        Enables the feature to block sync originating from domains that are not present in the safe recipients list

    .Parameter GrooveBlockOption
        Controls whether or not a tenant’s users can sync OneDrive for Business libraries with the old OneDrive for Business sync client

    .Parameter DisableReportProblemDialog
#>

param( 
    [Parameter(Mandatory = $true, ParameterSetName = 'FileExclusion')]
    [string]$ExcludedFileExtensions,
    [Parameter(Mandatory = $true, ParameterSetName = 'Blocking')]
    [string]$DomainGuids,
    [Parameter(Mandatory = $true, ParameterSetName = 'GrooveBlock')]
    [ValidateSet('OptOut', 'HardOptin', 'SoftOptin')]
    [switch]$GrooveBlockOption,
    [Parameter(Mandatory = $true, ParameterSetName = 'ReportProblem')]
    [bool]$DisableReportProblemDialog,
    [Parameter(ParameterSetName = 'Blocking')]
    [switch]$BlockMacSync,
    [Parameter(ParameterSetName = 'Blocking')]
    [switch]$Enable    
)

Import-Module Microsoft.Online.SharePoint.PowerShell

try{
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'} 
    
    if($PSCmdlet.ParameterSetName -eq 'FileExclusion'){
        $cmdArgs.Add('ExcludedFileExtensions' , $ExcludedFileExtensions)
    }
    elseif($PSCmdlet.ParameterSetName -eq 'Blocking'){
        $cmdArgs.Add('BlockMacSync' , $BlockMacSync)
        $cmdArgs.Add('Enable' , $Enable)
        $guids = $DomainGuids.Split(',')
        $cmdArgs.Add('DomainGuids' , $guids)
    }
    elseif($PSCmdlet.ParameterSetName -eq 'GrooveBlock'){
        $cmdArgs.Add('GrooveBlockOption' , $GrooveBlockOption)
    }
    elseif($PSCmdlet.ParameterSetName -eq 'ReportProblem'){
        $cmdArgs.Add('DisableReportProblemDialog' , $DisableReportProblemDialog)
    }

    $result = Set-SPOTenantSyncClientRestriction  @cmdArgs | Select-Object *
      
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $result
    }
    else {
        Write-Output $result 
    }    
}
catch{
    throw
}
finally{
}