#Requires -Version 4.0

<#
.SYNOPSIS
    Retrieves the size of all shares

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
    https://github.com/scriptrunner/ActionPacks/tree/master/WinFileManagement/Shares

.Parameter SpecialShares
    Indicates that the shares to be numerated should be special. Admin share, default shares, IPC$ share are examples of special shares

.Parameter IncludeHidden
    Indicates that shares that are created and used internally are also enumerated
#>

[CmdLetBinding()]
Param(
    [bool]$SpecialShares,
    [switch]$IncludeHidden
)

$Script:output = @()
try{
    $objShares = Get-SmbShare -IncludeHidden:$IncludeHidden -Special $SpecialShares -ErrorAction Stop  `
                            | Select-Object Path,Name,ShareType | Where-Object {$_.ShareType -eq 'FileSystemDirectory'} | Sort-Object Name 
    foreach($share in $objShares){
        $childs = Get-ChildItem -Path $share.Path -Force -Recurse | Measure-Object -Property Length -Sum
        $size = $childs.Sum
        if($null -eq $size){
            $size = "0"
        }        
        $Script:output += "Size of share:$($share.Name) path:$($share.Path) is $($size)"
    }    
                                
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