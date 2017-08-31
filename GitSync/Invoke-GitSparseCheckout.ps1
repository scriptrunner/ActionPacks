<#
.SYNOPSIS
    Checkout the given SubDirs of a Git repository to ScriptRunner Library.

.DESCRIPTION
    Checkout a Git repository to ScriptRunner Library.
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
    Path to the ScriptRunner Library. Default value is 'C:\ProgramData\AppSphere\ScriptMgr'.

.PARAMETER GitExePath
    Path to the git execuatble. Default value is 'C:\Program Files\Git\cmd\git.exe'.

.PARAMETER Cleanup
    Cleanup the local repository before initialize a new repository.
    All files and sub directories in the repository path will be removed.
    Default value is 'false'.

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
    This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
    The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
    The terms of use for ScriptRunner do not apply to this script. In particular, AppSphere AG assumes no liability for the function, 
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of AppSphere AG.
    © AppSphere AG

#>

[CmdletBinding(DefaultParameterSetName='Default')]
param(
    [Parameter(Mandatory = $true)]
    [string]$GitRepoUrl,
    [Parameter(Mandatory = $true, ParameterSetName='PrivateRepository')]
    [pscredential]$GitUserCredential,
    [string[]]$SparseDirs,
    [string]$Branch = 'master',
    [string]$SRLibraryPath = 'C:\ProgramData\AppSphere\ScriptMgr\Git',
    [string]$GitExePath = 'C:\Program Files\Git\cmd\git.exe',
    [bool]$Cleanup = $false
)

$userNamePattern = [regex]'^([^_]|[a-zA-Z0-9]){1}[a-zA-Z0-9]{1,14}$'

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

function Test-LastExitcode ([string]$ActionFailed) {
    if ($LASTEXITCODE -ne 0) {
        $err = $Error[0]
        if($err){
            if($SRXEnv){
                $SRXEnv.ResultMessage += $err.Exception | Out-String
            }
        }
        $Script:currentLocation | Set-Location
        Write-Error -Message "Failed to run '$ActionFailed' with '$LASTEXITCODE'." -ErrorAction 'Stop'
    }
}

function Invoke-GitCommand ([string[]]$ArgumentList){
    if(-not $ArgumentList){
        throw "Invalid command. No arguments specified."
    }
    try {
        # redirect stderr of git.exe to stdout
        # see: https://stackoverflow.com/questions/2095088/error-when-calling-3rd-party-executable-from-powershell-when-using-an-ide
        $result = (& cmd.exe '/c' "`"$script:GitExePath`" 2>&1" $ArgumentList)
        $result
        Add-SRXResultMessage -Message $result
    }    
    catch {
        $_
    }    
    finally{
        Test-LastExitcode -ActionFailed "git $ArgumentList"
    }    
}    

if(-not (Test-Path -Path $GitExePath -ErrorAction SilentlyContinue)){
    throw "'$GitExePath' does not exist."
}

if(-not (Test-Path -Path $SRLibraryPath -ErrorAction SilentlyContinue)){
    New-Item -Path $SRLibraryPath -ItemType 'Directory' -Force
}
if($GitRepoUrl.Trim().StartsWith('https://') -or $GitRepoUrl.Trim().StartsWith('http://')){
    if($PSCmdlet.ParameterSetName -eq 'PrivateRepository'){
        $i = $GitRepoUrl.IndexOf('://')
        $i += 3
        if(-not ($GitUserCredential.UserName -match $userNamePattern)){
            throw "Invalid UserName '$($GitUserCredential.UserName)'. Do not use a email address. Use the git username instead."
        }
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


if(Test-Path -Path $SRLibraryPath -ErrorAction SilentlyContinue){
    $Script:currentLocation = Get-Location
    # get repo name => set as base dir
    $i = $gitUrl.LastIndexOf('/')
    $i++
    $repo = $gitUrl.Substring($i)
    $repo = $repo.Split('.')[0]
    Write-Output "Repository: '$repo'."
    $SRLibraryPath = Join-Path -Path $SRLibraryPath -ChildPath $repo
    if(-not (Test-Path -Path $SRLibraryPath -ErrorAction SilentlyContinue)){
        "Create directory '$SRLibraryPath' ..."
        $null = New-Item -Path $SRLibraryPath -ItemType Directory -Force
    }
    Set-Location -Path $SRLibraryPath
    if($Cleanup){
        "Cleanup '$SRLibraryPath' ..."
        Get-ChildItem | Remove-Item -Recurse -Force
        Get-ChildItem -Hidden | Remove-Item -Recurse -Force
    }
    Write-Output "Local repository path: '$SRLibraryPath'."

    # init new local repo
    [string[]]$arguments = @('init')
    Invoke-GitCommand $arguments
    # activate sparse checkout
    $arguments = @('config', 'core.sparseCheckout', 'true')
    Invoke-GitCommand $arguments
    # do not prompt for user/password
    $arguments = @('config', 'core.askPass', 'false')
    Invoke-GitCommand $arguments

    $result = (& cmd.exe '/c' "`"$GitExePath`" 2>&1" @('remote', 'show'))
    if($result -and ($result -eq 'origin')){
        Invoke-GitCommand @('remote', 'update')
    }
    else{
        Invoke-GitCommand @('remote', 'add', '-f', 'origin',  $gitUrl)
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
    Invoke-GitCommand $arguments

    $Script:currentLocation | Set-Location
}
else {
    Write-Error -Message "ScriptRunner Library Path '$SRLibraryPath' does not exist." -ErrorAction 'Stop'
}

"done."