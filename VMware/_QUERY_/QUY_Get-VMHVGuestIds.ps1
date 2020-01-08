#Requires -Version 4.0
# Requires -Modules VMware.PowerCLI

<#
.SYNOPSIS
    Retrieves the available guest ids

.DESCRIPTION

.NOTES
    This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
    The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
    The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
    © ScriptRunner Software GmbH

.COMPONENT
    Requires Module VMware.PowerCLI

.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/VMware/_QUERY_

.Parameter VIServer
    Specifies the IP address or the DNS name of the vSphere server to which you want to connect

.Parameter VICredential
    Specifies a PSCredential object that contains credentials for authenticating with the server
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential
)

Import-Module VMware.PowerCLI

try{
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
   
    $ids = Get-VMGuest -Server $Script:vmServer -VM * -ErrorAction Stop | Where-Object -Property GuestID -ne $null `
                        | Select-Object OSFullName,GuestId -Unique | Sort-Object -Property OSFullName

    foreach($item in $ids){
        if([System.String]::IsNullOrEmpty($item.GuestId) -eq $false){            
            if($SRXEnv) {
                $null = $SRXEnv.ResultList.Add($item.GuestId.toString())
                $null = $SRXEnv.ResultList2.Add($item.OSFullName) # Display
            }
            else{
                Write-Output $item.OSFullName
            }
        }
    }
}
catch{
    throw
}
finally{    
    if($null -ne $Script:vmServer){
        Disconnect-VIServer -Server $Script:vmServer -Force -Confirm:$false
    }
}