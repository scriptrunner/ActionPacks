<#
.SYNOPSIS
    Checkout the given SubDirs of a branch of a Git repository to ScriptRunner Library.
.DESCRIPTION
    Checkout a branch of a Git repository to ScriptRunner Library.
    If you specifiy SparseDirs, only the given directories will be checked out.
    If you want to checkout a private repository, you must specify the GitUserCredential.
.PARAMETER GitRepoUrl
    URL of the git repository. e.g. 'https://github.com/ScriptRunner/ActionPacks.git'
.PARAMETER GitUserCredential
    Credential of a git user, who is authorized to access the given git repository.
    Note that an email address is not a valid account name. You must use this ParameterSet for private repositories.
.PARAMETER SparseDirs
    Specify the list of subfolders you want to check out. If empty, all files will be checked out.
    Example: "ActiveDirectory/*", "O365/*"
.PARAMETER Branch
    The remote branch to check out. Default value is 'master'.
.PARAMETER SRLibraryPath
    Check out the branch of the repository to this path at the ScriptRunner Library. Default value is 'C:\ProgramData\ScriptRunner\ScriptMgr\Git'.
.PARAMETER GitExePath
    Path to the git execuatble. Default value is 'C:\Program Files\Git\cmd\git.exe'.
.PARAMETER Cleanup
    Cleanup the local repository before initializing a new repository.
    All files and sub directories in the repository path will be removed before checking out the repo.
.PARAMETER CheckSSL
    Do a SSL Check on git communication?
.Parameter AddRepositoryNameToPath
    Creates a folder with the repository name in the storage path, if not available. 
    Otherwise, the system synchronizes directly to the storage path.
    Default value is 'true'.
.Parameter RemoveGitConfig
    Deletes the hidden folder .git and .github from the storage path, after checking out the repo.
    This will also cleanup the local repository path before initializing a new repository.
    All files and sub directories in the repository path will be removed before checking out the repo.
.PARAMETER TestConnection
    Test connection to the GitRepoUrl.
.NOTES
    General notes
    -------------------
    Run as scheduled ScriptRunner Action on target 'Direct Service Execution'.
    Requires Git for Windows
    https://git-for-windows.github.io
    Optional: Git Credential Manager for Windows 
    https://github.com/Microsoft/Git-Credential-Manager-for-Windows
    Disclaimer
    -------------------
    This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts does not require ScriptRunner.
    The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
    The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
    © ScriptRunner Software GmbH
#>

[CmdletBinding(DefaultParameterSetName='Default')]
param(
    [Parameter(Mandatory = $true)]
    [string]$GitRepoUrl,
    [Parameter(Mandatory = $true, ParameterSetName='PrivateRepository')]
    [pscredential]$GitUserCredential,
    [string[]]$SparseDirs,
    [string]$Branch = 'master',
    [string]$SRLibraryPath = 'C:\ProgramData\ScriptRunner\ScriptMgr\Git',
    [bool]$AddRepositoryNameToPath = $true,
    [string]$GitExePath = 'C:\Program Files\Git\cmd\git.exe',
    [switch]$Cleanup,
    [switch]$RemoveGitConfig,
    [switch]$CheckSSL,
    [switch]$TestConnection
)

$userNamePattern = [regex]'^([^_]|[a-zA-Z0-9]){1}(?:[a-zA-Z0-9._]|-(?=[a-zA-Z0-9])){0,38}$'
$showError = $true

function Add-SRXResultMessage ([string[]] $Message) {
    if($SRXEnv -and $Message){
        if([string]::IsNullOrEmpty($SRXEnv.ResultMessage)){
            $SRXEnv.ResultMessage = $Message
        }
        else{
            $SRXEnv.ResultMessage += $Message | Out-String
        }
    }
}

function Test-LastExitcode ([string]$ActionFailed, [bool]$ErrorOutput = $true) {
    if ($LASTEXITCODE -ne 0) {
        if($ErrorOutput){
            $err = $Error[0]
            if($err){
                if($SRXEnv){
                    $SRXEnv.ResultMessage += $err.Exception | Out-String
                }
            }
            $Script:currentLocation | Set-Location
            Write-Error -Message "Failed to run '$ActionFailed' with exit code '$LASTEXITCODE'." -ErrorAction 'Stop'
        }
        else{
            # surpress git error output, if giturl contains cleartext password
            Write-Error -Message "Failed to run 'git command' with exit code '$LASTEXITCODE'." -ErrorAction 'Stop'
        }
    }
}

function Invoke-GitCommand ([string[]]$ArgumentList, [bool]$ErrorOutput = $true){
    if(-not $ArgumentList){
        throw "Invalid command. No arguments specified."
    }
    try {
        # redirect stderr of git.exe to stdout
        # see: https://stackoverflow.com/questions/2095088/error-when-calling-3rd-party-executable-from-powershell-when-using-an-ide
        $result = (& cmd.exe '/c' "`"$script:GitExePath`" 2>&1" $ArgumentList)
        if($ErrorOutput){
            $result
            Add-SRXResultMessage -Message $result
        }
    }
    catch {
        if($ErrorOutput){
            $_
        }
    }
    finally{
        Test-LastExitcode -ActionFailed "git $ArgumentList" -ErrorOutput $ErrorOutput
    }
}

# entry point
if(-not (Test-Path -Path $GitExePath -ErrorAction SilentlyContinue)){
    throw "'$GitExePath' does not exist."
}

if(-not (Test-Path -Path $SRLibraryPath -ErrorAction SilentlyContinue)){
    New-Item -Path $SRLibraryPath -ItemType 'Directory' -Force
}

if($TestConnection.IsPresent){
    $testUri = (Split-Path -Path $GitRepoUrl -Parent) -replace '\\', '/'
    $result = Invoke-WebRequest -Uri $testUri -UseBasicParsing -UseDefaultCredentials -ErrorAction SilentlyContinue
    if($null -eq $result -or $result.StausCode -ge 300){
        throw "Failed to send/receive request to/from '$testUri'. ($result.StatusCode - $result.StatusDescription)"
    }
}

if($GitRepoUrl.Trim().StartsWith('https://') -or $GitRepoUrl.Trim().StartsWith('http://')){
    if($PSCmdlet.ParameterSetName -eq 'PrivateRepository'){
        $i = $GitRepoUrl.IndexOf('://')
        $i += 3
        if(-not ($GitUserCredential.UserName -match $userNamePattern)){
            if($GitUserCredential.UserName.Contains('@')){
                Write-Error "Do not use an email address. Use the git user name instead." -ErrorAction Continue
            }
            throw "Invalid UserName '$($GitUserCredential.UserName)'. The user name does not match the GitHub user name pattern."
        }
        # surpress git output, if giturl contains cleartext password
        $showError = $false
        $cred = New-Object -TypeName 'System.Net.NetworkCredential' -ArgumentList @($GitUserCredential.UserName, $GitUserCredential.Password)
        $gitUrl = $GitRepoUrl.Insert($i, $cred.UserName + ':' + $([uri]::EscapeDataString($cred.Password)) + '@')
        $GitRepoUrl = $($gitUrl.Replace($([uri]::EscapeDataString($cred.Password)), '*****'))
    }
    else{
        $gitUrl = $GitRepoUrl
    }
}
else {
    Write-Error -Message "Invalid git URL '$GitRepoUrl'." -ErrorAction 'Stop'
}

Invoke-WebRequest -Uri $gitUrl -UseBasicParsing -UseDefaultCredentials -ErrorAction SilentlyContinue 


if(Test-Path -Path $SRLibraryPath -ErrorAction SilentlyContinue){
    $Script:currentLocation = Get-Location
    # get repo name => set as base dir
    $i = $gitUrl.LastIndexOf('/')
    $i++
    $repo = $gitUrl.Substring($i)
    $repo = $repo.Split('.')[0]
    Write-Output "Repository: '$repo'."
    if($AddRepositoryNameToPath){
        $SRLibraryPath = Join-Path -Path $SRLibraryPath -ChildPath $repo
    }
    if(-not (Test-Path -Path $SRLibraryPath -ErrorAction SilentlyContinue)){
        "Create directory '$SRLibraryPath' ..."
        $null = New-Item -Path $SRLibraryPath -ItemType Directory -Force
    }
    Set-Location -Path $SRLibraryPath
    if($Cleanup.IsPresent -or $RemoveGitConfig.IsPresent){
        if([string]::Equals($SRLibraryPath.Trim('\'), "$(Join-Path -Path $env:ProgramData -ChildPath 'ScriptRunner\ScriptMgr')")){
            Write-Error "Cannot remove path '$($SRLibraryPath)'!" -ErrorAction Stop
        }
        "Cleanup '$SRLibraryPath' ..."
        Get-ChildItem | Remove-Item -Recurse -Force
        Get-ChildItem -Hidden | Remove-Item -Recurse -Force
    }
    Write-Output "Local repository path: '$SRLibraryPath'."

    # init new local repo
    [string[]]$arguments = @('init')
    Invoke-GitCommand -ArgumentList $arguments -ErrorOutput $showError
    # activate sparse checkout
    $arguments = @('config', 'core.sparseCheckout', 'true')
    Invoke-GitCommand -ArgumentList $arguments -ErrorOutput $showError
    # do not prompt for user/password
    $arguments = @('config', 'core.askPass', 'false')
    Invoke-GitCommand -ArgumentList $arguments -ErrorOutput $showError

    # SSL handling
     if($CheckSSL.IsPresent){
        $arguments = @('config', 'http.sslVerify', 'false')
        Invoke-GitCommand -ArgumentList $arguments -ErrorOutput $showError
     }

    $result = (& cmd.exe '/c' "`"$GitExePath`" 2>&1" @('remote', 'show'))
    if($result -and ($result -eq 'origin')){
        Invoke-GitCommand -ArgumentList @('remote', 'update') -ErrorOutput $showError
    }
    else{
        Invoke-GitCommand -ArgumentList @('remote', 'add', '-f', 'origin',  $gitUrl) -ErrorOutput $showError
    }
    # setup sparse dirs
    if(Test-Path -Path '.\.git\info\sparse-checkout' -ErrorAction SilentlyContinue){
        'Found previous sparse dirs:'
        Get-Content -Path '.\.git\info\sparse-checkout' -Force -Encoding UTF8
        "Remove previous sparse dirs ..."
        Remove-Item -Path '.\.git\info\sparse-checkout' -Force
    }
    foreach($subDir in $SparseDirs){
        "Add sparse dir:"
        $subDir = $subDir.Replace('\', '/').Trim()
        Add-Content -Value $subDir -Path '.\.git\info\sparse-checkout' -Force -Encoding UTF8 -PassThru
    }
    # checkout specified branch 
    $arguments = @('checkout', $Branch)
    Invoke-GitCommand -ArgumentList $arguments -ErrorOutput $showError

    $arguments = @('pull', 'origin')
    Invoke-GitCommand -ArgumentList $arguments -ErrorOutput $showError

    $Script:currentLocation | Set-Location

    if($RemoveGitConfig.IsPresent){
        [string]$gitConfigPath = Join-Path -Path $SRLibraryPath -ChildPath ".git"
        if(Test-Path -Path $gitConfigPath -ErrorAction SilentlyContinue){
            "Remove '$($gitConfigPath)' ..."
            Remove-Item -Path $gitConfigPath -Recurse -Force -Confirm:$false -ErrorAction Stop
        }
        $gitConfigPath = Join-Path -Path $SRLibraryPath -ChildPath ".github"
        if(Test-Path -Path $gitConfigPath -ErrorAction SilentlyContinue){
            "Remove '$($gitConfigPath)' ..."
            Remove-Item -Path $gitConfigPath -Recurse -Force -Confirm:$false -ErrorAction Stop
        }
    }

    Write-Output "done."
}
else {
    Write-Error -Message "ScriptRunner Library Path '$SRLibraryPath' does not exist." -ErrorAction 'Stop'
}
