#Requires -Version 4.0

<#
.SYNOPSIS
    Starts a process on the local computer

.DESCRIPTION

.NOTES
    This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
    The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
    The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
    © ScriptRunner Software GmbH

.COMPONENT

.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/WinSystemManagement/Processes

.Parameter FilePath
    Specifies the path (optional) and file name of the program that runs in the process

.Parameter AccessAccount
    Specifies a user account that has permission to perform this action

.Parameter ArgumentList
    Specifies parameters or parameter values to use when starting the process

.Parameter NoNewWindow
    Start the new process in the current console window, by default Windows PowerShell opens a new window.

.Parameter Verb
    Indicates that this cmdlet gets the file version information for the program that runs in the process.

.Parameter WindowStyle
    Specifies the state of the window that is used for the new process

.Parameter WorkingDirectory
    Specifies the location of the executable file or document that runs in the process
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$FilePath,
    [PSCredential]$AccessAccount,
    [string]$ArgumentList,
    [switch]$NoNewWindow,
    [Validateset("Edit", "Open", "Print", "Runas", "PrintTo", "Play")]
    [string]$Verb ,
    [Validateset("Normal","Hidden","Minimized","Maximized")]
    [string]$WindowStyle = "Normal",
    [string]$WorkingDirectory
)

try{
    [string[]]$Properties = @('Name','ID','FileVersion','UserName','PagedMemorySize','PrivateMemorySize','VirtualMemorySize','TotalProcessorTime','Path','CPU','StartTime')

    if([System.String]::IsNullOrWhiteSpace($ArgumentList) -eq $true){
        $ArgumentList = " "
    }
    if([System.String]::IsNullOrWhiteSpace($WorkingDirectory) -eq $true){
        $WorkingDirectory = " "
    }
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'PassThru' = $null
                            'WorkingDirectory' = $WorkingDirectory
                            'FilePath' = $FilePath
                            'ArgumentList' = $ArgumentList
                            }
    if([System.String]::IsNullOrWhiteSpace($Verb) -eq $false){
        $cmdArgs.Add('Verb', $Verb)
    }
    if($null -ne $AccessAccount){
        $cmdArgs.Add('Credential' ,$AccessAccount)
    }
    if($NoNewWindow -eq $false){
        $cmdArgs.Add('WindowStyle', $WindowStyle)
    }
    else {
        $cmdArgs.Add('NoNewWindow',$null)
    }
        
    $Script:process = Start-Process @cmdArgs

    $result = Get-Process -ID $Script:process.ID -IncludeUserName | Select-Object $Properties
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
}