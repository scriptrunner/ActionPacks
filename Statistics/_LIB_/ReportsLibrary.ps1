function ConvertTo-ResultHtml (){
    <#
    .SYNOPSIS
        Generates a ScriptRunner report via ConvertTo-Html

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
        https://github.com/scriptrunner/ActionPacks/tree/master/Reporting/_LIB_ 

    .Parameter Result
       Script result to be converted to html

    .Parameter CreateHttpLinks
        Create links from the http entries
    #>
    param(
        [Parameter(Mandatory=$true)]
        [AllowNull()]
        $Result,
        [switch]$CreateHttpLinks
    )
    if($null -eq $Result){
        return 
    }
    if($null -eq $SRXEnv){
        Write-Output "Not running on ScriptRunner PowerShell Host"
    }
    else{
        [string]$preContent = "<div class='sr-header'>
            <div class='sr-info'>
               <ul>
                   <li>Action: $($SrxEnv.SRXDisplayName)</li>
                   <li>Started by: $($SrxEnv.SRXStartedBy)</li>
                   <li>Date: $(Get-Date -Format 'MM/dd/yyy HH:mm:ss')</li>
               </ul>
            </div>
            <div class='sr-image'>
                <img src='./logo.svg'/>
            </div>
        </div>"
        $SRXEnv.ResultMessage = $Result
        [string]$head = @"
                <meta http-equiv="content-type" content="text/html; charset=utf-8">
                <title>$($SrxEnv.SRXDisplayName) $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $($SrxEnv.SRXStartedBy)</title>
"@
        [string]$resHtml = ($Result | ConvertTo-Html -PreContent $preContent -CssUri './sr-table.css' `
            -Head $head -As Table)
             #- Title ("Result: $($SrxEnv.SRXDisplayName) $(Get-Date -Format 'MM/dd/yyy HH:mm:ss')-$($SrxEnv.SRXStartedBy)") -As Table)
        
        if($CreateHttpLinks -eq $true){
            [string]$inplace
            [string]$link
            [int]$start = $resHtml.IndexOf('>http',0)
            [int]$end
            while($start -ge 0){
                $start ++
                $end = $resHtml.IndexOf('<',$start )
                $link = $resHtml.Substring($start,($end - $start))
                $linkPart = "<a href='" + $link + "' target=_blank>$($link)</a>"
                $resHtml = $resHtml.Substring(0,$start) + $linkPart + $resHtml.Substring($end)
                $start = $resHtml.IndexOf('>http',($start + $linkPart.Length))
            }
        }

        $SRXEnv.ResultHtml = $resHtml
    }
}