#Requires -Version 4.0

<#
.SYNOPSIS
    Retrieves a list of objects

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
    https://github.com/scriptrunner/ActionPacks/tree/master/WinFileManagement/FolderAndFiles

.Parameter StartObjectName
    Specifies the start folder or drive

.Parameter ObjectType
    Specifies the type of the objects

.Parameter ShowSizes
    Shows the sizes of the objects

.Parameter ObjectsCumulated
    Cumulates the objects and there sizes

.EXAMPLE

#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$StartObjectName,
    [ValidateSet("All","Folders","Files")]
    [string]$ObjectType = "All",
    [switch]$ShowSizes,
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
    if($ObjectsCumulated -eq $false){
       foreach($item in $Script:childs){
            if($ObjectType -eq "All" -and $item.PSIsContainer -eq $true -and $Script:output.Count -gt 0){
                $tmp= ([ordered] @{ 
                    Name = ""
                    Size = ""
                })
                $Script:output += New-Object PSObject -Property $tmp
            }
            $tmp= ([ordered] @{ 
                Name = $item.Name
                Size = $item.Length
            })
            $Script:output += New-Object PSObject -Property $tmp 
            if($ObjectType -eq "All" -and $item.PSIsContainer -eq $true){
                $tmp= ([ordered] @{ 
                Name = "-----"
                    Size = ""
                })
                $Script:output += New-Object PSObject -Property $tmp
            }
        }
    }
    # 
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $Script:output
    }
    else{
        Write-Output $Script:output
    }
}
catch{
    throw
}
finally{ 
}