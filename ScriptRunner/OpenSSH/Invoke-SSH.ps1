<#
    .SYNOPSIS
    Executes commands or shell scripts at a remote host via ssh batch mode.

    .DESCRIPTION
    Executes commands or shell scripts at a remote host via ssh batch mode.

    .PARAMETER UserName
    The user name that is used to authenticate at the remote host.

    .PARAMETER RemoteHost
    The machine name or IP address of the remote host.

    .PARAMETER Commands
    The commands to execute at the remote host.

    .PARAMETER ShellScriptPath
    EXPERIMENTAL: File path of the shell script at the ScriptRunner service host.

    .PARAMETER Encoding
    The encoding of the shell script file.

    .PARAMETER PrintScriptContent
    Display the content of shell script.

    .PARAMETER Port
    The port of ssh service at the remote host.

#>

[CmdletBinding()]
param
(
    [Parameter(Mandatory=$true)]
    [string]$UserName,
    [Parameter(Mandatory=$true)]
    [string]$RemoteHost,
    [Parameter(Mandatory=$true, ParameterSetName='Commands')]
    [string[]]$Commands,
    [Parameter(Mandatory=$true, ParameterSetName='ShellScript')]
    [string]$ShellScriptPath,
    [Parameter(ParameterSetName='ShellScript')]
    [string]$Encoding = 'UTF8',
    [Parameter(ParameterSetName='ShellScript')]
    [switch]$PrintScriptContent,
    [ValidateRange(1,65535)]
    [int]$Port = 22
)

if ($PSCmdlet.ParameterSetName -eq 'Commands'){
    foreach ($command in $Commands) {
        "$UserName@$RemoteHost `$ $command"
        & cmd.exe '/c' "ssh.exe 2>&1 -p $Port -o `"BatchMode yes`" $UserName@$RemoteHost $command"
        if($LASTEXITCODE -ne 0){
            throw "SSH failed with ExitCode '$LASTEXITCODE'."
        }
    }
}
elseif ($PSCmdlet.ParameterSetName -eq 'ShellScript') {
    if(Test-Path -Path $ShellScriptPath -ErrorAction SilentlyContinue){
        "### E X P E R I M E N T A L ###"
        $sh = Get-Content -Path $ShellScriptPath -Encoding $Encoding -Raw | ForEach-Object -Process { $_ -replace "`r`n","`n" }
        $scriptName = (Split-Path -Path $ShellScriptPath -Leaf).Replace(" ", [string]::Empty)
        $cmdSequence = "rm -fr ~/tmp_asr && mkdir -p ~/tmp_asr && cat >> ~/tmp_asr/$scriptName && sed -i 's/\r$//g' ~/tmp_asr/$scriptName && chmod +x ~/tmp_asr/$scriptName && ~/tmp_asr/$scriptName && rm -fr ~/tmp_asr"
        if($PrintScriptContent.IsPresent){
            "##### $scriptName #####"
            $sh
            "##### EOF '$scriptName' #####"
            "`nRun  $UserName@$RemoteHost `"$cmdSequence`" ...`n"
        }
        $sh | & ssh.exe -p $Port -o `"BatchMode yes`" $UserName@$RemoteHost "$cmdSequence"

        if($LASTEXITCODE -ne 0){
            throw "SSH failed with ExitCode '$LASTEXITCODE'."
        }
    }
    else {
        throw "Path '$ShellScriptPath' does not exist."
    }
}
else{
    throw "Invalid ParameterSet '$($PSCmdlet.ParameterSetName)'."
}
