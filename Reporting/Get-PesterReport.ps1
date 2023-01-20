#Requires -Version 5.0

<#
    .SYNOPSIS
        Creates an html report from the pester test report
    
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
        https://github.com/scriptrunner/ActionPacks/tree/master/Reporting
        
    .Parameter Report
        [sr-en] Pester test report XML file
        [sr-de] Pester Test XML-Reportdatei
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$Report
)

try{
    [int]$tCases = 0
    [int]$tSkipped = 0
    [int]$sSkipped = 0
    [string]$headerHtml = ''
    [string]$suitesSummary = ''
    [string]$htmlResult = ''
    [string]$tmpHtml = ''
    [string]$overHtml = ''
#region functions
    function CheckPSDrive(){
        <#
            .SYNOPSIS
                Checks if a ps drive has already been created for sharing and creates this if necessary

            .Parameter Path
                Path to the share file or share directory
        #>

        param(
            [string]$Path
        )

        if($Path.StartsWith('\\') -eq $true){
            [string]$tmp = ''
            [string[]]$splitted = $Path.split('\')
            if($splitted[$splitted.Count-1].IndexOf('.') -le 0){ # is directory
                $tmp = $Path
            }
            else{ # is file
                $tmp = $Path.Replace("\$($splitted[$splitted.Count-1])",'')
            }
            $chkDrive = Get-PSDrive -PSProvider FileSystem 
            if(($chkDrive.Root -contains $tmp) -eq $false){
                [string]$newName = [System.Guid]::NewGuid().ToString()
                $Script:drives += $newName
                if($null -ne $ShareAccessAccount){
                    $null = New-PSDrive -Scope Script -Name $newName -Root $tmp -PSProvider FileSystem -Credential $ShareAccessAccount -Confirm:$false
                }
                else{
                    $null = New-PSDrive -Scope Script -Name $newName -Root $tmp -PSProvider FileSystem -Confirm:$false
                }
            }
        }
    }
#endregion functions
    CheckPSDrive -Path $Report
    if((Test-Path -Path $Report) -eq $false){
        throw "Import file $($Report) not found"
    }
    [xml]$xmlReport = Get-Content -Path $Report

    # Header
    GetHtmlHeader -TestName $xmlReport.SelectSingleNode('//testsuites').Attributes['name'].Value -Header ([ref]$headerHtml)
    # Suites
    $suiteNodes = $xmlReport.SelectNodes('//testsuite')
    foreach($suite in $suiteNodes){
        BuildSuiteSummaryHtml -SuiteNode $suite -Id $tCases -SuiteCollection ($suiteNodes.Count -gt 1) -Skipped ([ref]$sSkipped) -SuiteResult ([ref]$tmpHtml) -OverviewResult ([ref]$overHtml)
        $tSkipped += $sSkipped
        $suitesSummary += $overHtml
        $htmlResult += $tmpHtml
        BuildSuiteParameterHtml -SuiteNode $suite -Id $tCases -HtmlResult ([ref]$tmpHtml)
        $htmlResult += $tmpHtml
        BuildSuiteTestcasesHtml -SuiteNode $suite -Id $tCases -HtmlResult ([ref]$tmpHtml)
        $htmlResult += $tmpHtml
        $tCases++
    }
    # suites summary
    if($tCases -gt 1){ 
        BuildSuitesSummaryHeaderHtml -HtmlResult ([ref]$suitesSummary)
        $htmlResult = $suitesSummary + $htmlResult
    }
    # Report summary
    BuildReportSummaryHtml -SuitesNode $xmlReport.SelectSingleNode('//testsuites') -SuiteCount $tCases -SkippedCount $tSkipped -HtmlResult ([ref]$tmpHtml)
    $htmlResult = $tmpHtml + $htmlResult
    # footer
    GetHtmlFooter -Footer ([ref]$tmpHtml)
    $htmlResult += $tmpHtml

    [int]$bodyIdx = $headerHtml.IndexOf('<body>') + 6
<#      
    $tmpHtml = "$($headerHtml.Substring(0,$bodyIdx))$($htmlResult)$($headerHtml.Substring($bodyIdx))"
    $tmpHtml | Out-File C:\Transfer\Pester\newreport.html # todo #>

    $SRXEnv.ResultHtml = "$($headerHtml.Substring(0,$bodyIdx))$($htmlResult)$($headerHtml.Substring($bodyIdx))"
    if($null -ne $SRXEnv) {
        $SRXEnv.ResultMessage = "Report created"
    }
    else{
        Write-Output "Report created"
    }
}
catch{
    throw
}
finally{
}