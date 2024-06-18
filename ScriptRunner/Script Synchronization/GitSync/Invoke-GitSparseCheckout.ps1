<#
.SYNOPSIS
	Checkout the given SubDirs of a branch of a Git repository to ScriptRunner Library.
.DESCRIPTION
	Checkout a branch of a Git repository to ScriptRunner Library.
	If you specifiy SparseDirs, only the given directories will be checked out.
	If you want to checkout a private repository, you must specify the GitUserCredential.
	NOTE:
	The script requires [Git for Windows](https://git-for-windows.github.io).
	You can download the tool set from [Git for Windows Releases at Github](https://github.com/git-for-windows/git/releases).
	You must also install the [Git Credential Manager](https://github.com/git-ecosystem/git-credential-manager#readme),
	which is shipped with the Git for Windows installation.
.PARAMETER GitRepoUrl
	URL of the git repository. e.g.
	- 'https://github.com/my-org/my-repo.git.git'
	- 'https://gitlab.com/my-org/my-repo.git'
	- 'https://bitbucket.org/my-org/my-repo.git'
	- 'https://dev.azure.com/my-org/my-project/_git/my-repo'
.PARAMETER GitUserCredential
	Credential of a git user, who is authorized to access the given git repository.
	Note that an email address is not a valid account name. You must use this ParameterSet for private repositories.
	The username must not be empty and must match the AllowedUsernamePattern.
	You can use a personal access token (PAT) with BasicAuth headers as an alternative to username/password authentication in the url.
	Add the PAT as a password to the Credential and set the UseBasicAuth switch.
.PARAMETER AllowedUsernamePattern
	A regular expression to vaidate the username of the GitUserCredential.
.PARAMETER IgnoreUsername
	The username of the GitUserCredential will not be validated and will not be used for authentication but must not be empty.
.PARAMETER SparseDirs
	Specify the list of subfolders you want to check out. If empty, all files will be checked out.
	Example: "ActiveDirectory/*", "O365/*"
.PARAMETER Branch
	The remote branch to check out. Default value is 'main'.
.PARAMETER SRLibraryPath
	Check out the branch of the repository to this path at the ScriptRunner Library.
	Default value is 'C:\ProgramData\ScriptRunner\ScriptMgr\Git'.
.PARAMETER GitExePath
	Path to the git execuatble. Default value is 'C:\Program Files\Git\cmd\git.exe'.
.PARAMETER Cleanup
	Cleanup the local repository before initializing a new repository.
	All files and sub directories in the repository path will be removed before checking out the repo.
.PARAMETER CheckSSL
	Do a SSL Check on git communication
.Parameter AddRepositoryNameToPath
	Creates a folder with the repository name in the storage path, if not available.
	Otherwise, the system synchronizes directly to the storage path.
	Default value is 'true'.
.Parameter RemoveGitConfig
	Deletes the hidden folder .git and .github from the storage path, after checking out the repo.
	This will also cleanup the local repository path before initializing a new repository.
	All files and sub directories in the repository path will be removed before checking out the repo.
.PARAMETER UseSSH
	Uses ssh instead of https. Used for private repos and public key autentication.
	For use with a system account, the known_hosts and id_rsa file must be placed in "C:\Windows\System32\config\systemprofile\.ssh\"
	Only the GitRepoUrl and SRLibraryPath parameter will be reflected when this swich is used.
.PARAMETER UseBasicAuth
	You can use a personal access token (PAT) with a BasicAuth header to authenticate as an alternate to user/password authentication in the URL.
	This parameter is intended for use with Azure DevOps Service or Azure DevOps Server, for example.
	Add the PAT as a password to the Credential and set this switch. Use the IgnoreUsername switch to skip the username of the GitUserCredential for authentication.
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

.LINK
	Git for Windows
	https://github.com/git-for-windows/git#readme

.LINK
	Git for Windows Releases
	https://github.com/git-for-windows/git/releases

.LINK
	Git Credential Manager
	https://github.com/git-ecosystem/git-credential-manager#readme

.LINK
	Azure DevOps Services or Server - Use personal access tokens to authenticate
	https://learn.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate

.LINK
	GitLab - Clone repository using personal access token
	https://docs.gitlab.com/ee/user/profile/personal_access_tokens.html#clone-repository-using-personal-access-token

.LINK
	GitHub - Using a personal access token on the command line
	https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens#using-a-personal-access-token-on-the-command-line

.LINK
	Bitbucket - Using Repository Access Tokens with the Git command line interface
	https://support.atlassian.com/bitbucket-cloud/docs/using-access-tokens/

.LINK
	Sync Git repositories to ScriptRunner
	https://github.com/scriptrunner/ActionPacks/tree/master/ScriptRunner/Script%20Synchronization/GitSync#readme
#>

[CmdletBinding(DefaultParameterSetName='Default')]
param(
	[Parameter(Mandatory = $true)]
	[string]$GitRepoUrl,
	[string]$Branch = 'main',
	[string[]]$SparseDirs,
	[string]$SRLibraryPath = 'C:\ProgramData\ScriptRunner\ScriptMgr\Git',
	[bool]$AddRepositoryNameToPath = $true,
	[string]$GitExePath = 'C:\Program Files\Git\cmd\git.exe',
	[switch]$Cleanup,
	[switch]$RemoveGitConfig,
	[switch]$CheckSSL,
	[Parameter(Mandatory = $true, ParameterSetName='SSH')]
	[switch]$UseSSH,
	[Parameter(Mandatory = $true, ParameterSetName='PrivateRepository')]
	[pscredential]$GitUserCredential,
	[Parameter(ParameterSetName='PrivateRepository')]
	[string]$AllowedUsernamePattern = '^([^_]|[a-zA-Z0-9]){1}(?:[a-zA-Z0-9._]|-(?=[a-zA-Z0-9])){0,38}$',
	[Parameter(ParameterSetName='PrivateRepository')]
	[switch]$UseBasicAuth,
	[Parameter(ParameterSetName='PrivateRepository')]
	[switch]$IgnoreUsername
)

$showError = $true

function Add-SRXResultMessage ([string[]] $Message) {
	if($SRXEnv -and $Message) {
		if([string]::IsNullOrEmpty($SRXEnv.ResultMessage)) {
			$SRXEnv.ResultMessage = $Message
		}
		else{
			$SRXEnv.ResultMessage += $Message | Out-String
		}
	}
}

function Test-LastExitcode
{
	[CmdletBinding()]
	param (
		[string]$ActionFailed,
		[switch]$ErrorOutput
	)

	if ($LASTEXITCODE -ne 0) {
		$Script:currentLocation | Set-Location
		if($ErrorOutput.IsPresent) {
			$err = $Error[0]
			if($err) {
				if($SRXEnv) {
					$SRXEnv.ResultMessage += $err.Exception | Out-String
				}
				else {
					$err.Exception | Out-String
				}
			}
			Write-Error -Message "Failed to run '$ActionFailed' with exit code '$LASTEXITCODE'." -ErrorAction 'Stop'
		}
		else{
			# surpress git error output, if giturl contains cleartext password
			Write-Error -Message "Failed to run 'git command' with exit code '$LASTEXITCODE'." -ErrorAction 'Stop'
		}
	}
}

function Invoke-GitCommand
{
	[Diagnostics.CodeAnalysis.SuppressMessageAttribute('InjectionRisk.CommandInjection', '', Scope='Function')]
	[CmdletBinding()]
	param (
		[Parameter(Mandatory)]
		[string[]]$ArgumentList,
		[switch]$ErrorOutput,
		[switch]$Passthru
	)

	if($ArgumentList.Count -eq 0) {
		throw "Invalid command. No arguments specified."
	}
	try {
		$gitConfigArgs = @()
		if($script:UseBasicAuth.IsPresent) {
			[string]$base64Cred = ''
			if($IgnoreUsername.IsPresent) {
				$base64Cred = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes(":$($script:GitUserCredential.GetNetworkCredential().Password)"))
			}
			else {
				$base64Cred = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("$($script:GitUserCredential.UserName):$($script:GitUserCredential.GetNetworkCredential().Password)"))
			}
			$gitConfigArgs = @('-c', "http.extraHeader=`"Authorization: Basic $base64Cred`"")
		}
		# redirect stderr of git.exe to stdout
		# see: https://stackoverflow.com/questions/2095088/error-when-calling-3rd-party-executable-from-powershell-when-using-an-ide
		$result = (& cmd.exe '/c' "`"$script:GitExePath`" 2>&1 $gitConfigArgs $ArgumentList")
		if($ErrorOutput.IsPresent) {
			$result
			Add-SRXResultMessage -Message $result
		}
		if(!$ErrorOutput.IsPresent -and $Passthru.IsPresent) {
			$result
		}
	}
	catch {
		if($ErrorOutput.IsPresent) {
			$_
		}
	}
	finally {
		Test-LastExitcode -ActionFailed "git $($gitConfigArgs[0]) $ArgumentList" -ErrorOutput:$ErrorOutput
		#Test-LastExitcode -ActionFailed "git $($gitConfigArgs[0]) $ArgumentList" -ErrorOutput
	}
}

# entry point
if(-not (Test-Path -Path $GitExePath -ErrorAction SilentlyContinue)) {
	throw "'$GitExePath' does not exist."
	if('git.exe' -ne (Split-Path -Path $GitExePath -Leaf)) {
		throw "'$GitExePath' is not valid."
	}
}

if(-not (Test-Path -Path $SRLibraryPath -ErrorAction SilentlyContinue)) {
	New-Item -Path $SRLibraryPath -ItemType 'Directory' -Force
}

# needs a refactoring
if ($UseSSH.IsPresent) {
	Set-Location -Path $SRLibraryPath
	Invoke-GitCommand -ArgumentList @('clone', "$($GitRepoUrl)") -Passthru
	exit 0
}

if($GitRepoUrl.Trim().StartsWith('https://') -or $GitRepoUrl.Trim().StartsWith('http://')) {
	if(-not $UseBasicAuth.IsPresent -and $PSCmdlet.ParameterSetName -eq 'PrivateRepository') {
		$i = $GitRepoUrl.IndexOf('://')
		$i += 3
		if([string]::IsNullOrEmpty($GitUserCredential.UserName)) {
			# GetNetworkCredential() => The value for UserName is not in the correct format.
			throw "Username cannot be empty."
		}
		if($IgnoreUsername.IsPresent) {
			$gitUrl = $GitRepoUrl.Insert($i, $([uri]::EscapeDataString($GitUserCredential.GetNetworkCredential().Password)) + '@')
		}
		else {
			$usernamePattern = [regex]$AllowedUsernamePattern
			if(-not ($GitUserCredential.UserName -match $usernamePattern)) {
				if($GitUserCredential.UserName.Contains('@')) {
					Write-Error "An email address is not allowed as username. Use the git user name instead." -ErrorAction Continue
				}
				throw "Invalid UserName '$($GitUserCredential.UserName)'. The user name does not match the allowed user name pattern."
			}
			$gitUrl = $GitRepoUrl.Insert($i, $GitUserCredential.UserName + ':' + $([uri]::EscapeDataString($GitUserCredential.GetNetworkCredential().Password)) + '@')
		}
		# surpress git error output, if giturl contains cleartext password
		$showError = $false
		$GitRepoUrl = $($gitUrl.Replace($([uri]::EscapeDataString($GitUserCredential.GetNetworkCredential().Password)), '*****'))
	}
	else {
		$gitUrl = $GitRepoUrl
	}
}
else {
	Write-Error -Message "Invalid git URL '$GitRepoUrl'." -ErrorAction 'Stop'
}

# "Request http get '$GitRepoUrl' ..."
# Invoke-WebRequest -Uri $gitUrl -Method Get -UseBasicParsing -ErrorAction SilentlyContinue | Select-Object Encoding, StatusCode, StatusDescription

if(Test-Path -Path $SRLibraryPath -ErrorAction SilentlyContinue) {
	$Script:currentLocation = Get-Location

	"get commit ID of 'refs/heads/$($Branch)' from '$($GitRepoUrl)'..."
	Invoke-GitCommand -ArgumentList @('ls-remote', '--heads', $gitUrl, $Branch) -Passthru

	# get repo name => set as base dir
	$i = $gitUrl.LastIndexOf('/')
	$i++
	$repo = $gitUrl.Substring($i)
	$repo = $repo.Split('.')[0]
	Write-Output "Repository: '$repo'."
	if($AddRepositoryNameToPath) {
		$SRLibraryPath = Join-Path -Path $SRLibraryPath -ChildPath $repo
	}
	if(-not (Test-Path -Path $SRLibraryPath -ErrorAction SilentlyContinue)) {
		"Create directory '$SRLibraryPath' ..."
		$null = New-Item -Path $SRLibraryPath -ItemType Directory -Force
	}
	Set-Location -Path $SRLibraryPath
	if($Cleanup.IsPresent -or $RemoveGitConfig.IsPresent) {
		if([string]::Equals($SRLibraryPath.Trim('\'), "$(Join-Path -Path $env:ProgramData -ChildPath 'ScriptRunner\ScriptMgr')")) {
			Write-Error "Cannot remove path '$($SRLibraryPath)'!" -ErrorAction Stop
		}
		"Cleanup '$SRLibraryPath' ..."
		Get-ChildItem | Remove-Item -Recurse -Force
		Get-ChildItem -Hidden | Remove-Item -Recurse -Force
	}
	Write-Output "Local repository path: '$SRLibraryPath'."

	# init new local repo
	[string[]]$arguments = @('init')
	Invoke-GitCommand -ArgumentList $arguments -ErrorOutput:$showError
	# activate sparse checkout
	$arguments = @('config', 'core.sparseCheckout', 'true')
	Invoke-GitCommand -ArgumentList $arguments -ErrorOutput:$showError
	# do not prompt for user/password
	$arguments = @('config', 'core.askPass', 'false')
	Invoke-GitCommand -ArgumentList $arguments -ErrorOutput:$showError

	# SSL handling
	if($CheckSSL.IsPresent) {
		$arguments = @('config', 'http.sslVerify', 'false')
		Invoke-GitCommand -ArgumentList $arguments -ErrorOutput:$showError
	 }

	$result = Invoke-GitCommand -ArgumentList @('remote', 'show') -Passthru
	if($result -and ($result -eq 'origin')) {
		Invoke-GitCommand -ArgumentList @('remote', 'update') -ErrorOutput:$showError
	}
	else{
		Invoke-GitCommand -ArgumentList @('remote', 'add', '-f', 'origin',  $gitUrl) -ErrorOutput:$showError
	}
	# setup sparse dirs
	if(Test-Path -Path '.\.git\info\sparse-checkout' -ErrorAction SilentlyContinue) {
		'Found previous sparse dirs:'
		Get-Content -Path '.\.git\info\sparse-checkout' -Force -Encoding UTF8
		"Remove previous sparse dirs ..."
		Remove-Item -Path '.\.git\info\sparse-checkout' -Force
	}
	foreach($subDir in $SparseDirs) {
		"Add sparse dir:"
		$subDir = $subDir.Replace('\', '/').Trim()
		Add-Content -Value $subDir -Path '.\.git\info\sparse-checkout' -Force -Encoding UTF8 -PassThru
	}
	# checkout specified branch
	$arguments = @('checkout', $Branch)
	Invoke-GitCommand -ArgumentList $arguments -ErrorOutput:$showError

	$arguments = @('pull', 'origin')
	Invoke-GitCommand -ArgumentList $arguments -ErrorOutput:$showError

	$Script:currentLocation | Set-Location

	if($RemoveGitConfig.IsPresent) {
		[string]$gitConfigPath = Join-Path -Path $SRLibraryPath -ChildPath ".git"
		if(Test-Path -Path $gitConfigPath -ErrorAction SilentlyContinue) {
			"Remove '$($gitConfigPath)' ..."
			Remove-Item -Path $gitConfigPath -Recurse -Force -Confirm:$false -ErrorAction Stop
		}
		$gitConfigPath = Join-Path -Path $SRLibraryPath -ChildPath ".github"
		if(Test-Path -Path $gitConfigPath -ErrorAction SilentlyContinue) {
			"Remove '$($gitConfigPath)' ..."
			Remove-Item -Path $gitConfigPath -Recurse -Force -Confirm:$false -ErrorAction Stop
		}
	}

	Write-Output "done."
}
else {
	Write-Error -Message "ScriptRunner Library Path '$SRLibraryPath' does not exist." -ErrorAction 'Stop'
}
