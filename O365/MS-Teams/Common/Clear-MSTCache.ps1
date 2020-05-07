#Requires -Version 5.0

<#
    .SYNOPSIS
        Clears the Microsoft Teams client cache 
    
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
        https://github.com/scriptrunner/ActionPacks/tree/master/O365/MS-Teams/Common
             
    .Parameter ComputerName
        Specifies the computer on which the cache are cleared 
                
    .Parameter AccessAccount
        Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used

    .Parameter StopTeamsProcess
        Stop Microsoft Teams process before clean the cache
#>

param( 
    [string]$ComputerName,
    [pscredential]$AccessAccount,
    [switch]$StopTeamsProcess
)

[string[]]$AppDataLocations = @('\Microsoft\teams\application cache\cache',
                        '\Microsoft\teams\blob_storage',
                        '\Microsoft\teams\databases',
                        '\Microsoft\teams\cache',
                        '\Microsoft\teams\gpucache',
                        '\Microsoft\teams\Indexeddb',
                        '\Microsoft\teams\Local Storage',
                        '\Microsoft\teams\tmp')

try{ 
    if([System.String]::IsNullOrWhiteSpace($ComputerName)){
        if($SRXEnv){                      
            $Computername = [System.Net.DNS]::GetHostByAddress($SRXEnv.SRXStartedIP).HostName
        }else{
            $ComputerName = [System.Net.DNS]::GetHostByName('').HostName
        }        
    }  
    [hashtable]$invArgs = @{'ErrorAction' = 'Stop'
                            'ComputerName' = $ComputerName
                            }
    if($null -ne $AccessAccount){
        $invArgs.Add('Credential', $AccessAccount)
    }
    if($StopTeamsProcess -eq $true){
        try{
            Invoke-Command @invArgs -ScriptBlock{
                Get-Process -ProcessName Teams | Stop-Process -Force
                Start-Sleep -Seconds 5
                Write-Output "Microsoft Teams process sucessfully stopped"
            }
        }
        catch{
            Write-Output "Error on stop Microsoft Teams process"
            Write-Output $_.Exception.Message
        }
    }
    # clear AppData folder
    Invoke-Command @invArgs -ScriptBlock{
        foreach($fol in $Using:AppDataLocations){
            $path = "$($env:APPDATA)$($fol)"
            if((Test-Path -Path $path) -eq $true){
                $null = Get-ChildItem -Path $path | Remove-Item -Confirm:$false -Recurse
            }
        }
    }
    Write-Output "AppData cache cleared"
    
    if($SRXEnv) {
        $SRXEnv.ResultMessage = "Microsoft Teams client cache on $($ComputerName) cleared"
    }
    else{
        Write-Output "Microsoft Teams client cache on $($ComputerName) cleared"
    }
}
catch{
    throw 
}
finally{
}