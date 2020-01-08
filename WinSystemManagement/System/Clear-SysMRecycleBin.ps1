#Requires -Version 5.0

<#
    .SYNOPSIS
        Clears recycle bin on computer
    
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
        https://github.com/scriptrunner/ActionPacks/tree/master/WinSystemManagement/System
                
    .Parameter ComputerName
        Specifies the computer on which deletes the content of the recycle bin
                
    .Parameter AccessAccount
        Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used

    .Parameter RecycleBinDrives        
        Specifies the drive letters for which this cmdlet clears the recycle bin, comma separated. 
        Is the parameter empty, all items are cleared
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$ComputerName,
    [pscredential]$AccessAccount,
    [string]$RecycleBinDrives
)

try{ 
    if([System.String]::IsNullOrWhiteSpace($ComputerName)){
        $ComputerName = [System.Net.DNS]::GetHostByName('').HostName
    }          
    [hashtable]$cmdArgs = @{'ErrorAction' = 'SilentlyContinue'
                'Force' = $null
                'Confirm' = $false
                } 
    if([System.String]::IsNullOrWhiteSpace($RecycleBinDrives) -eq $false){
        $cmdArgs.Add('DriveLetter',$RecycleBinDrives.Split(','))
    }

    [hashtable]$invArgs = @{'ErrorAction' = 'Stop'
                            'ComputerName' =$ComputerName
                            }

    if($null -ne $AccessAccount){
        $invArgs.Add('Credential', $AccessAccount)
    }
    Invoke-Command @invArgs -ScriptBlock{
        $CopyParams = $using:cmdArgs
        Clear-RecycleBin @CopyParams
    }

    if($SRXEnv) {
        $SRXEnv.ResultMessage = "Recycle bin cleared"
    }
    else{
        Write-Output "Recycle bin cleared"
    }        
}
catch{
    throw 
}
finally{
    
}