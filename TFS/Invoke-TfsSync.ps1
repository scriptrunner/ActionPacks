<#
.SYNOPSIS
    Get latest version of a TFS Team Project.

.DESCRIPTION
    Sync latest version of a TFS team project to local ScriptRunner script repository.

.PARAMETER TfsServerUri
    Uri of the Team Foundation Server project collection.
    e.g. 'http://myTfsServer.MyDomain.com:8080/tfs/DefaultProjectCollection'

.PARAMETER TfsCredential
    Credential for TFS access.

.PARAMETER TeamProject
    Team project path.
    e.g. '$/MyProjectName/MyBranch/SubFolderA/SubFolderB'

.PARAMETER SRLibraryPath
    Path to the ScriptRunner script repository.
    e.g. 'C:\ProgramData\AppSphere\ScriptMgr\TFS'

.EXAMPLE
    Invoke-TfsSync -TfsServerUri 'http://myTfsServer.MyDomain.com:8080/tfs/DefaultProjectCollection' -TeamProject '$/MyProjectName/MyBranch/SubFolderA/SubFolderB' -TfsCredential (Get-Credential -UserName 'myDomain\myUser' -Message 'TfsCredential')
    
.NOTES
    Use this script if Visual Studio is not installed at the machine. 
    Requires libraryies of TFS Power Tools. You can download install the TFS Power Tools from the Visual Studio Marketplace.
    https://marketplace.visualstudio.com/items?itemName=AdamRDriscoll.PowerShellToolsforVisualStudio2017-18561
    https://marketplace.visualstudio.com/items?itemName=AdamRDriscoll.PowerShellToolsforVisualStudio2015
    https://marketplace.visualstudio.com/items?itemName=AdamRDriscoll.PowerShellToolsforVisualStudio2013

#>


param(
    [Parameter(Mandatory = $true)]
    [string]$TfsServerUri,
    [Parameter(Mandatory = $true)]
    [pscredential]$TfsCredential,
    [Parameter(Mandatory = $true)]
    [string]$TeamProject,
    [string]$SRLibraryPath = 'C:\ProgramData\AppSphere\ScriptMgr\TFS'
)

$ErrorActionPreference = 'Stop'

if(-not $env:TFSPowerToolDir){
    throw "TFS Power Tools are not installed."
}

if(-not (Test-Path -Path $SRLibraryPath -ErrorAction SilentlyContinue)){
    New-Item -Path $SRLibraryPath -ItemType 'Directory' -Force
}

$dlls = "Microsoft.TeamFoundation.Client.dll", "Microsoft.TeamFoundation.VersionControl.Client.dll"

foreach ($dll in $dlls){
    $dllPath = Join-Path -Path $env:TFSPowerToolDir -ChildPath $dll
    Add-Type -Path $dllPath
}


$teamProjectFolder = $TeamProject
if ($teamProjectFolder.IndexOf('$/') -eq 0){
    $teamProjectFolder = $teamProjectFolder.Substring(2)
}
$localProjectPath = Join-Path -Path $SRLibraryPath -ChildPath $teamProjectFolder

# Connect to production-TFS
Write-Output "Getting latest version of '$TeamProject' from '$TfsServerUri' ..."
$tfsTeamProjects = [Microsoft.TeamFoundation.Client.TfsTeamProjectCollectionFactory]::GetTeamProjectCollection($TfsServerUri)
$tfsTeamProjects.Credentials = $TfsCredential.GetNetworkCredential()
$tfsTeamProjects.ClientCredentials.Windows.Credentials = $TfsCredential.GetNetworkCredential()
[Microsoft.TeamFoundation.VersionControl.Client.VersionControlServer]$vcServer = $tfsTeamProjects.GetService([type] "Microsoft.TeamFoundation.VersionControl.Client.VersionControlServer")

# TryGetWorkspace is sometimes buggy and doesn't return an existing workspace
# Delete existing workspace manually before if that happens
$workspace = $vcServer.TryGetWorkspace($localProjectPath)
if($workspace){
    try{
        $workspace.Get()
        Write-Output "Sync of latest version of '$TeamProject' to '$teamProjectFolder' succeed."
        exit
    }
    catch{
        $workspace = $null
    }
}

[bool]$isTempWorkspace = $false
# create Workspace if it doesn't exists
if (-not $workspace) {
    $workSpaceGuid = "Temp_" + [System.Guid]::NewGuid().Guid
    Write-Output "No workspace found, creating temporary workspace '$workSpaceGuid' ..."
    $workspace = $vcServer.CreateWorkspace($workSpaceGuid)
    $workspace.Map($Teamproject, $localProjectPath)
    $isTempWorkspace = $true
}

$itemSpecFullTeamProj = New-Object Microsoft.TeamFoundation.VersionControl.Client.ItemSpec($Teamproject, "Full")
$fileRequest = New-Object Microsoft.TeamFoundation.VersionControl.Client.GetRequest($itemSpecFullTeamProj, [Microsoft.TeamFoundation.VersionControl.Client.VersionSpec]::Latest)
if(-not $workspace.Get($fileRequest, [Microsoft.TeamFoundation.VersionControl.Client.GetOptions]::GetAll)){
        throw "Get '$TeamProject' from '$TfsServerUri' failed."
}

if ($isTempWorkspace) {
    Write-Output "Deleting temporary workspace '$workSpaceGuid' ..."
    if(-not $workspace.Delete()){
        throw "WorkSpace '$workSpaceGuid' could not be deleted."
    }
}

Write-Output "Sync of latest version of '$TeamProject' to '$teamProjectFolder' succeed."