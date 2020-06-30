#Requires -Version 4.0

<#
.SYNOPSIS
    Generates a report with a list of objects

.DESCRIPTION

.NOTES
    This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
    The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
    The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
    © ScriptRunner Software GmbH

.COMPONENT    
    Requires Library Script ReportLibrary from the Action Pack Reporting\_LIB_

.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/WinFileManagement/_REPORTS_

.Parameter StartObjectName
    Specifies the start folder or drive

.Parameter ObjectType
    Specifies the type of the objects

.Parameter ObjectsCumulated
    Cumulates the objects and there sizes
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$StartObjectName,
    [ValidateSet("All","Folders","Files")]
    [string]$ObjectType = "All",
    [switch]$ObjectsCumulated 
)

try{
    $Script:output=@()
    if(-not (Test-Path -Path $StartObjectName)){
        throw "$($StartObjectName) not found"
    }
    if($ObjectType  -eq "All"){
        $Script:childs = Get-ChildItem -Path $StartObjectName -Force -Recurse 
        if($ObjectsCumulated -eq $true){
            $sum = $Script:childs | Measure-Object -Property Length -Sum
            $Script:output += "Count: $($Script:childs.Count) - Size: $($sum.Sum) bytes"
        }
    }
    elseif($ObjectType  -eq "Folders"){
        $Script:childs = Get-ChildItem -Path $StartObjectName -Force -Recurse -Directory
        if($ObjectsCumulated -eq $true){
            $sum = Get-ChildItem -Path $StartObjectName -Force -Recurse | Measure-Object -Property Length -Sum
            $Script:output += "Count: $($Script:childs.Count) - Size: $($sum.Sum) bytes"
        }
    }
    elseif($ObjectType  -eq "Files"){
        $Script:childs = Get-ChildItem -Path $StartObjectName -Force -Recurse -File
        if($ObjectsCumulated -eq $true){
            $sum = $Script:childs | Measure-Object -Property Length -Sum
            $Script:output += "Count: $($Script:childs.Count) - Size: $($sum.Sum) bytes"
        }
    } 
    [string]$path = ''
    if($ObjectsCumulated -eq $false){
       foreach($item in $Script:childs){
            $path = ''
            if($item.FullName.LastIndexOf('\') -gt 2){
                $path = $item.FullName.Substring(0,$item.FullName.LastIndexOf('\'))
            }
            $tmp= ([ordered] @{ 
                Name = $item.Name
                Path = $path
                'Size (MB)' = ([math]::round($item.Length/1MB, 3))
            })
            $Script:output += New-Object PSObject -Property $tmp 
        }
    }
    ConvertTo-ResultHtml -Result $Script:output
}
catch{
    throw
}
finally{ 
}