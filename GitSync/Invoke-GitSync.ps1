<#
.SYNOPSIS
Clone a Git repository to ScriptRunner Library or pull updates to a local repository.

.DESCRIPTION
Clone a Git repository to ScriptRunner Library or pull updates to a local repository.

.PARAMETER GitRepoUrl
URL of the git repository. e.g. 'https://github.com/PowerShell/PowerShell.git'

.PARAMETER GitUser
Credential of a git user, who is authorized to access the given git repo.

.PARAMETER SRLibraryPath
Path to the ScriptRunner Library Path. Default: 'C:\ProgramData\AppSphere\ScriptMgr'

.PARAMETER GitAction
Clone or pull the given git repo.

.NOTES
General notes
Run as scheduled ScriptRunner Action on target 'Direct Service Execution'.

Requires Git for Windows
https://git-for-windows.github.io

Optional: Git Credential Manager for Windows 
https://github.com/Microsoft/Git-Credential-Manager-for-Windows

#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$GitRepoUrl,
    [Parameter(Mandatory = $true)]
    [pscredential]$GitUser,
    [string]$SRLibraryPath = 'C:\ProgramData\AppSphere\ScriptMgr',
    [ValidateSet('clone','pull')]
    [string]$GitAction = 'pull'
)

if($GitRepoUrl.Trim().StartsWith('https://') -or $GitRepoUrl.Trim().StartsWith('http://')){
    $i = $GitRepoUrl.IndexOf('://')
    $i += 3
    $GitRepoUrl = $GitRepoUrl.Insert($i, $GitUser.UserName + "@")
    Write-Output "$GitAction $GitRepoUrl ..."
}
else {
    throw "Invalid git URL '$GitRepoUrl'."
}

if(Test-Path -Path $SRLibraryPath -ErrorAction SilentlyContinue){
    $currentLocation = Get-Location

    if($GitAction -eq 'pull'){
        $i = $GitRepoUrl.LastIndexOf('/')
        $i++
        $repo = $GitRepoUrl.Substring($i)
        $repo = $repo.Split('.')[0]
        Write-Output "Repository: '$repo'."
        $SRLibraryPath = Join-Path -Path $SRLibraryPath -ChildPath $repo
        Write-Output "Local repository path: '$SRLibraryPath'."
    }

    Set-Location -Path $SRLibraryPath -PassThru
    try {
        & git @($GitAction, $GitRepoUrl)
        
    }
    catch {
        $_.CategoryInfo
    }
    finally{
        $currentLocation | Set-Location -PassThru
        if ($LASTEXITCODE -ne 0) {
            $Error[0]
            throw "Error occured: '$($Error[0].FullyQualifiedErrorId) $($Error[0].ScriptStackTrace)'."
        }
    }

}
else {
    throw "ScriptRunner Library Path '$SRLibraryPath' does not exist."
}
