<#
.SYNOPSIS
Clone a Git repository to ScriptRunner Library or pull updates to a local repository.

.DESCRIPTION
Clone a Git repository to ScriptRunner Library or pull updates to a local repository.  

.NOTES
    This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
    The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
    The terms of use for ScriptRunner do not apply to this script. In particular, AppSphere AG assumes no liability for the function, 
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of AppSphere AG.
    © AppSphere AG
    
.PARAMETER GitRepoUrl
URL of the git repository. e.g. 'https://github.com/PowerShell/PowerShell.git'

.PARAMETER GitUserCredential
Credential of a git user, who is authorized to access the given git repo.

.PARAMETER GitUserName
UserName of a git user, who is authorized to access the given git repo.

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

[CmdletBinding(DefaultParameterSetName='Credential')]
param(
    [Parameter(Mandatory = $true)]
    [string]$GitRepoUrl,
    [Parameter(Mandatory = $true, ParameterSetName='Credential')]
    [pscredential]$GitUserCredential,
    [Parameter(Mandatory = $true, ParameterSetName='UserName')]
    [string]$GitUserName, 
    [string]$SRLibraryPath = 'C:\ProgramData\AppSphere\ScriptMgr\Git',
    [ValidateSet('clone','pull')]
    [string]$GitAction = 'pull'
)

if(-not (Test-Path -Path $SRLibraryPath -ErrorAction SilentlyContinue)){
    New-Item -Path $SRLibraryPath -ItemType 'Directory' -Force
}

if($GitRepoUrl.Trim().StartsWith('https://') -or $GitRepoUrl.Trim().StartsWith('http://')){
    $i = $GitRepoUrl.IndexOf('://')
    $i += 3
    if($PSCmdlet.ParameterSetName -eq 'Credential'){
        $cred = New-Object -TypeName 'System.Net.NetworkCredential' -ArgumentList @($GitUserCredential.UserName, $GitUserCredential.Password)
        $gitUrl = $GitRepoUrl.Insert($i, $cred.UserName + ':' + $([uri]::EscapeDataString($cred.Password)) + '@')
        Write-Output "$GitAction $($gitUrl.Replace($([uri]::EscapeDataString($cred.Password)), '*****')) ..."
    }
    if($PSCmdlet.ParameterSetName -eq 'UserName'){
        $gitUrl = $GitRepoUrl.Insert($i, $GitUserName + '@')
        Write-Output "$GitAction $gitUrl ..."
    }
}
else {
    Write-Error -Message "Invalid git URL '$GitRepoUrl'." -ErrorAction 'Stop'
}

if(Test-Path -Path $SRLibraryPath -ErrorAction SilentlyContinue){
    $currentLocation = Get-Location

    if($GitAction -eq 'pull'){
        $i = $gitUrl.LastIndexOf('/')
        $i++
        $repo = $gitUrl.Substring($i)
        $repo = $repo.Split('.')[0]
        Write-Output "Repository: '$repo'."
        $SRLibraryPath = Join-Path -Path $SRLibraryPath -ChildPath $repo
        Write-Output "Local repository path: '$SRLibraryPath'."
    }

    Set-Location -Path $SRLibraryPath
    try {
        $resultMessage = & 'git.exe' @($GitAction, $gitUrl)
        $resultMessage
    }
    catch {
        $_
    }
    finally{
        $currentLocation | Set-Location
        if($SRXEnv){
            $SRXEnv.ResultMessage = $resultMessage
        }
        if ($LASTEXITCODE -ne 0) {
            $err = $Error[0]
            $err
            if($SRXEnv){
                $SRXEnv.ResultMessage += $err.Exception
            }
            Write-Error -Message "Failed to $GitAction $GitRepoUrl" -ErrorAction 'Stop'
        }
    }
}
else {
    Write-Error -Message "ScriptRunner Library Path '$SRLibraryPath' does not exist." -ErrorAction 'Stop'
}
