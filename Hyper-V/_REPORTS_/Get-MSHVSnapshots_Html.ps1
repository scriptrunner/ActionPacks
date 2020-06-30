#Requires -Version 4.0
#Requires -Modules Hyper-V

<#
    .SYNOPSIS
        Generates a report with all snapshots
    
    .DESCRIPTION   
        Supports the execution on Windows Server 2016 / Windows 10 or newer

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires Module Hyper-V
        Requires Library Script ReportLibrary from the Action Pack Reporting\_LIB_

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/Hyper-V/_REPORTS_

    .Parameter HostName
        Specifies the name of the Hyper-V host

    .Parameter AccessAccount
        Specifies the user account that have permission to perform this action

    .Parameter SnapshotType
        Specifies the type of the snapshots to be retrieved  
#>

param(
    [string]$HostName,
    [PSCredential]$AccessAccount,
    [ValidateSet('All','Standard', 'Recovery', 'Planned', 'Missing', 'Replica', 'AppConsistentReplica','SyncedReplica')]
    [string]$SnapshotType = "All"
)

Import-Module Hyper-V

try {
    [string[]]$Properties = @('VMName','Name','SnapshotType','CreationTime','ParentSnapshotName')
    
    if([System.String]::IsNullOrWhiteSpace($HostName)){
        $HostName = "."
    }    
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'VMName' = '*'
                            }    
    
    if($null -eq $AccessAccount){
        $cmdArgs.Add('ComputerName', $HostName)
    }
    else {
        $Script:Cim = New-CimSession -ComputerName $HostName -Credential $AccessAccount
        $cmdArgs.Add('CimSession', $Script:Cim)
    }    

    if($SnapshotType -ne 'All'){
        $cmdArgs.Add('SnapshotType', $SnapshotType)
    }
    $output = Get-VMSnapshot @cmdArgs | Select-Object $Properties
    
    ConvertTo-ResultHtml -Result $output
}
catch {
    throw
}
finally{
    if($null -ne $Script:Cim){
        Remove-CimSession $Script:Cim 
    }
}