#Requires -Version 5.0

function BuildReportSummaryHtml{
    <#
        .SYNOPSIS
            Returns the report summary html

        .NOTES
            This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
            The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
            The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
            the use and the consequences of the use of this freely available script.
            PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
            © ScriptRunner Software GmbH

        .Parameter SuitesNode
            Testsuites XML node 
        .Parameter SuiteCount
            Number of Tests
        .Parameter SkippedCount
            Number of skipped Tests
        .Parameter HtmlResult  
            Reference parameter for result
        #>

        [CmdLetBinding()]
        Param(            
            [Parameter(Mandatory = $true)]
            [System.Xml.XmlNode]$SuitesNode,
            [int]$SuiteCount,
            [int]$SkippedCount,
            [Parameter(Mandatory = $true)]
            [ref]$HtmlResult
        )

        try{            
            $ret = New-Object PSCustomObject -Property ([Ordered] @{
                'Name' = $SuitesNode.Attributes['name'].Value
                'Time' = $SuitesNode.Attributes['time'].Value
                'Tests' = $SuitesNode.Attributes['tests'].Value
                'Errors' = "+X$($SuitesNode.Attributes['errors'].Value)"
                'Failures' = "+X$($SuitesNode.Attributes['failures'].Value)"
                'Disabled' = $SuitesNode.Attributes['disabled'].Value
                'Skipped' = $SkippedCount.ToString()
                'Testsuites' = $SuiteCount.ToString()
            })
            $HtmlResult.Value = "<h1>Report summary</h1>" + `
                (ConvertTo-Html -InputObject $ret -Fragment).Replace('<td>+X','<td class="SummaryFailures">') 
        }
        catch{
            throw
        }
        finally{
        }
}
function BuildSuitesSummaryHeaderHtml{
    <#
        .SYNOPSIS
            Returns the test suite header html

        .NOTES
            This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
            The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
            The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
            the use and the consequences of the use of this freely available script.
            PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
            © ScriptRunner Software GmbH

        .Parameter HtmlResult  
            Reference parameter for result
        #>

    param(
        [Parameter(Mandatory = $true)]
        [ref]$HtmlResult
    )

    $HtmlResult.Value = "<h2 id=""SuitesSummary"">Testsuites overview</h2>" + $HtmlResult.Value.Replace('<table>','<table class="SummaryAll">') 
}
function BuildSuiteParameterHtml{
    <#
        .SYNOPSIS
            Returns the test suite parameter html

        .NOTES
            This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
            The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
            The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
            the use and the consequences of the use of this freely available script.
            PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
            © ScriptRunner Software GmbH

        .Parameter SuiteNode
            Testsuite XML node 
        .Parameter Id  
            Suite counter
        .Parameter HtmlResult  
            Reference parameter for result
        #>

        [CmdLetBinding()]
        Param(            
            [Parameter(Mandatory = $true)]
            [System.Xml.XmlNode]$SuiteNode,
            [Parameter(Mandatory = $true)]
            [ref]$HtmlResult,
            [int]$Id
        )

        try{
            [PSCustomObject[]]$Paras = [PSCustomObject]@()
            foreach($para in $SuiteNode.SelectNodes('./properties/property')){
                $Paras += New-Object PSCustomObject -Property ([Ordered] @{
                    'Property' = "xYx_$($para.Attributes['name'].Value)"
                    'Value' = "xZx_$($para.Attributes['value'].Value)"
                })
            }
            [string]$result = ($Paras | ConvertTo-Html -Fragment).Replace('<table>','<table class="Suite">'). `
                                    Replace('<td>xYx_','<td class="PropertyName">'). `
                                    Replace('<td>xZx_','<td class="SuiteValue">')
            [int]$thStart = $result.IndexOf("<tr><th>Property") # remove header line
            [int]$thEnd = $result.IndexOf("Value</th></tr>") + 15
            $result = $result.Substring(0,$thStart) + $result.Substring($thEnd)
$HtmlResult.Value = @"
            <div>
                <h3 onclick="ToogleProperties($($id))">Properties
                    <span id="iconProp$($Id)" class="Button" title="Toggle">-<span>
                </h3>
                <div style="display:block" id="contentProp$($id)">
                    $($result)
                </div>
            </div>
"@
        }
        catch{
            throw
        }
        finally{
        }
}
function BuildSuiteSummaryHtml{
    <#
        .SYNOPSIS
            Returns the test suite summary html

        .NOTES
            This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
            The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
            The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
            the use and the consequences of the use of this freely available script.
            PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
            © ScriptRunner Software GmbH

        .Parameter SuiteNode
            Testsuite XML node 
        .Parameter OverviewResult  
            Reference parameter for overview html result
        .Parameter SuiteResult  
            Reference parameter for suite html result
        .Parameter Skipped  
            Reference parameter for skipped sum
        .Parameter Id  
            Suite counter
        .Parameter SuiteCollection  
            Single/Multi suite 
        #>

        [CmdLetBinding()]
        Param(            
            [Parameter(Mandatory = $true)]
            [System.Xml.XmlNode]$SuiteNode,
            [Parameter(Mandatory = $true)]
            [ref]$OverviewResult,
            [Parameter(Mandatory = $true)]
            [ref]$SuiteResult,
            [ref]$Skipped,
            [int]$Id,
            [bool]$SuiteCollection
        )

        try{
            [string]$html = ''
            $Skipped.Value = $SuiteNode.Attributes['skipped'].Value
            $ret = New-Object PSCustomObject -Property ([Ordered] @{
                'Time' = $SuiteNode.Attributes['time'].Value
                'Tests' = $SuiteNode.Attributes['tests'].Value
                'Errors' = "+X$($SuiteNode.Attributes['errors'].Value)"
                'Failures' = "+X$($SuiteNode.Attributes['failures'].Value)"
                'Disabled' = $SuiteNode.Attributes['disabled'].Value
                'Skipped' = $SuiteNode.Attributes['skipped'].Value
                'Host' = $SuiteNode.Attributes['hostname'].Value
            })
            $SuiteResult.Value = "<div style=""display:flex""><h2 id=""$($Id)"">$($SuiteNode.Attributes['package'].Value)</h2>"
            if($SuiteCollection -eq $true){
                $SuiteResult.Value += "<h2 style=""margin-left:auto""><a href=""#SuitesSummary"">Back to top</a></h2>"
            }
            $html = (ConvertTo-Html -InputObject $ret -Fragment).Replace('<td>+X','<td class="SummaryFailures">')
            $SuiteResult.Value += "</div>"  + $html 
            $OverviewResult.Value = '<a href="#' + $Id + '">' + $SuiteNode.Attributes['package'].Value + '</a>' + $html                
        }
        catch{
            throw
        }
        finally{
        }
}
function BuildSuiteTestcasesHtml{
    <#
        .SYNOPSIS
            Returns the test suite test cases html

        .NOTES
            This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
            The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
            The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
            the use and the consequences of the use of this freely available script.
            PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
            © ScriptRunner Software GmbH

        .Parameter SuiteNode
            Testsuite XML node 
        .Parameter Id  
            Suite counter
        .Parameter HtmlResult  
            Reference parameter for result
        #>

        [CmdLetBinding()]
        Param(            
            [Parameter(Mandatory = $true)]
            [System.Xml.XmlNode]$SuiteNode,
            [Parameter(Mandatory = $true)]
            [ref]$HtmlResult,
            [int]$Id
        )

        try{
            [PSCustomObject[]]$Cases = [PSCustomObject]@()
            foreach($case in $SuiteNode.SelectNodes('./testcase')){
                $Cases += New-Object PSCustomObject -Property ([Ordered] @{
                    'Name' = $case.Attributes['name'].Value
                    'State' = $case.Attributes['status'].Value
                    'Time' = $case.Attributes['time'].Value
                    'Class name' = $case.Attributes['classname'].Value
                    'Assertions' = $case.Attributes['assertions'].Value
                })
            }
            $Cases = ($Cases | ConvertTo-Html -Fragment).Replace('<table>','<table class="Suite">').  `
                                Replace("<td>Passed",'<td class="Passed">Passed').  `
                                Replace("<td>Skipped",'<td class="Skipped">Skipped'). `
                                Replace("<td>Failed",'<td class="Failed">Failed'). `
                                Replace("<td>NotRun",'<td class="NotRun">NotRun'). `
                                Replace('<td>','<td class="SuiteValue">'). `
                                Replace('<th>','<th class="ThSuite">')
$HtmlResult.Value = @"
            <div>
                <h3 onclick="ToogleCases($($id))">Test cases
                    <span id="iconCase$($Id)" class="Button" title="Toggle">-<span>
                </h3>
                <div style="display:block" id="contentCase$($id)">
                    $($Cases)
                </div>
            </div>
"@
        }                                   
        catch{
            throw
        }
        finally{
        }
}
function GetHtmlHeader{
    <#
        .SYNOPSIS
            Returns the html header with css

        .NOTES
            This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
            The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
            The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
            the use and the consequences of the use of this freely available script.
            PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
            © ScriptRunner Software GmbH

        .Parameter TestName
            Name of the testsuite 
        .Parameter Header  
            Reference parameter for result
    #>

    param(
        [Parameter(Mandatory = $true)]
        [ref]$Header,
        [string]$TestName
    )

$head = @"
    <meta http-equiv="content-type" content="text/html; charset=utf-8">
    <title>$($TestName) $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')</title>
    <link rel="shortcut icon" href="../images/favicon.ico" type="image/x-icon">
    <style>
            body,
            html {
                font-family: "Open Sans", "Segoe UI", Arial, serif;
            }

            a {
                text-decoration: var(--unnamed-decoration-underline);
                font: var(--unnamed-font-style-normal) normal var(--unnamed-font-weight-normal) var(--unnamed-font-size-16)/var(--unnamed-line-spacing-30) var(--unnamed-font-family-open-sans);
                letter-spacing: var(--unnamed-character-spacing-0);
                color: var(--unnamed-color-00497d);
                text-align: left;
                text-decoration: underline;
                font: normal normal normal 16px/30px Open Sans;
                letter-spacing: 0px;
                color: #00497D;
                opacity: 1;
            }

            h1 {
                font: var(--unnamed-font-style-normal) normal var(--unnamed-font-weight-600) var(--unnamed-font-size-32)/var(--unnamed-line-spacing-46) var(--unnamed-font-family-open-sans);
				letter-spacing: var(--unnamed-character-spacing--0-51);
				color: var(--dark);
				text-align: left;
				font: normal normal 600 32px/46px Open Sans;
				letter-spacing: -0.51px;
				color: #00192C;
				opacity: 1;
            }

            h2 {
                font: var(--unnamed-font-style-normal) normal var(--unnamed-font-weight-600) var(--unnamed-font-size-24)/var(--unnamed-line-spacing-29) var(--unnamed-font-family-open-sans);
                letter-spacing: var(--unnamed-character-spacing--0-38);
                color: var(--dark);
                text-align: left;
                font: normal normal 600 24px/29px Open Sans;
                letter-spacing: -0.38px;
                color: #00192C;
                opacity: 1;
            }

            h3 {
                font: var(--unnamed-font-style-normal) normal var(--unnamed-font-weight-600) var(--unnamed-font-size-20)/var(--unnamed-line-spacing-28) var(--unnamed-font-family-open-sans);
                letter-spacing: var(--unnamed-character-spacing--0-08);
                color: var(--dark);
                text-align: left;
                font: normal normal 600 20px/28px Open Sans;
                letter-spacing: -0.08px;
                color: #00192C;
                opacity: 1;
            }

            span.Button {
                border: 2px solid #00497D;
                border-radius: 6px;
                border-spacing: 0;
                cursor:pointer;
                padding-top: 5px;
                padding-right: 10px;
                padding-bottom: 5px;
                padding-left: 10px;
            }

            table {
                width: 100%;
                background: #F3F6F9 0% 0% no-repeat padding-box;
                border-radius: 6px;
                opacity: 1;
            }

            table.SummaryAll {
                margin-bottom:20px;
            }

            table.Suite {
                background: var(--white) 0% 0% no-repeat padding-box;
                background: #FFFFFF 0% 0% no-repeat padding-box;
                border: 1px solid #D6DAE2;
                border-radius: 6px;
                border-spacing: 0;
                opacity: 1;
            }

            th {
                font: var(--unnamed-font-style-normal) normal var(--unnamed-font-weight-normal) var(--unnamed-font-size-16)/22px var(--unnamed-font-family-open-sans);
                letter-spacing: var(--unnamed-character-spacing-0);
                text-align: left;
                font: normal normal normal 16px/22px Open Sans;
                letter-spacing: 0px;
                color: #4B5466;
                opacity: 1;
                padding-top: 10px;
                padding-right: 16px;
                padding-bottom: 0px;
                padding-left: 16px;
            }

            th.ThSuite {
                border-bottom: 1px solid #D6DAE2;
                padding-bottom: 10px; 
            }

            td {
                font: var(--unnamed-font-style-normal) normal var(--unnamed-font-weight-600) var(--unnamed-font-size-16)/22px var(--unnamed-font-family-open-sans);
                letter-spacing: var(--unnamed-character-spacing-0);
                color: var(--dark);
                text-align: left;
                font: normal normal 600 16px/22px Open Sans;
                letter-spacing: 0px;
                color: #00192C;
                opacity: 1;
                padding: 10px 16px; 
            }

            td.SummaryFailures {
                font: var(--unnamed-font-style-normal) normal var(--unnamed-font-weight-600) var(--unnamed-font-size-16)/22px var(--unnamed-font-family-open-sans);
                letter-spacing: var(--unnamed-character-spacing-0);
                color: var(--red);
                text-align: left;
                font: normal normal 600 16px/22px Open Sans;
                letter-spacing: 0px;
                color: #BB4441;
                opacity: 1;
            }

            td.PropertyName {
                font: var(--unnamed-font-style-normal) normal var(--unnamed-font-weight-normal) var(--unnamed-font-size-16)/22px var(--unnamed-font-family-open-sans);
                letter-spacing: var(--unnamed-character-spacing-0);
                text-align: left;
                font: normal normal normal 16px/22px Open Sans;
                letter-spacing: 0px;
                color: #4B5466;
                border-bottom: 1px solid #D6DAE2;
                opacity: 1;
            }            

            td.SuiteValue {
                font: var(--unnamed-font-style-normal) normal var(--unnamed-font-weight-600) var(--unnamed-font-size-16)/22px var(--unnamed-font-family-open-sans);
                letter-spacing: var(--unnamed-character-spacing-0);
                color: var(--dark);
                text-align: left;
                font: normal normal 600 16px/22px Open Sans;
                letter-spacing: 0px;
                color: #00192C;
                border-bottom: 1px solid #D6DAE2;
                opacity: 1;
            }

            td.Failed {
                background: #F2DBDA 0% 0% no-repeat padding-box;
                border-radius: 4px;
                opacity: 1;
                font: var(--unnamed-font-style-normal) normal var(--unnamed-font-weight-normal) 14px/16px var(--unnamed-font-family-open-sans);
                letter-spacing: var(--unnamed-character-spacing-0);
                color: var(--red);
                text-align: left;
                font: normal normal normal 14px/16px Open Sans;
                letter-spacing: 0px;
                color: #BB4441;
                border-bottom: 1px solid #D6DAE2;
                opacity: 1;
            }

            td.Passed {
                background: #CAF3DB 0% 0% no-repeat padding-box;
                border-radius: 4px;
                font: var(--unnamed-font-style-normal) normal var(--unnamed-font-weight-normal) 14px/16px var(--unnamed-font-family-open-sans);
                letter-spacing: var(--unnamed-character-spacing-0);
                text-align: left;
                font: normal normal normal 14px/16px Open Sans;
                letter-spacing: 0px;
                color: #26804C;
                border-bottom: 1px solid #D6DAE2;
                opacity: 1;
            }

            td.Skipped {
                background: var(---badff5) 0% 0% no-repeat padding-box;
                background: #BADFF5 0% 0% no-repeat padding-box;
                border-radius: 4px;
                font: var(--unnamed-font-style-normal) normal var(--unnamed-font-weight-normal) 14px/16px var(--unnamed-font-family-open-sans);
                letter-spacing: var(--unnamed-character-spacing-0);
                color: var(--blue-medium);
                text-align: left;
                font: normal normal normal 14px/16px Open Sans;
                letter-spacing: 0px;
                color: #1E5497;
                border-bottom: 1px solid #D6DAE2;
                opacity: 1;
            }

            td.NotRun {
                background: #708090 0% 0% no-repeat padding-box;
                background: #708090 0% 0% no-repeat padding-box;
                border-radius: 4px;
                font: var(--unnamed-font-style-normal) normal var(--unnamed-font-weight-normal) 14px/16px var(--unnamed-font-family-open-sans);
                letter-spacing: var(--unnamed-character-spacing-0);
                color: #FFFFFF;
                text-align: left;
                font: normal normal normal 14px/16px Open Sans;
                letter-spacing: 0px;
                color: #FFFFFF;
                border-bottom: 1px solid #D6DAE2;
                opacity: 1;
            }
    </style>
"@
    $Header.Value = ((ConvertTo-Html -Head $head -InputObject $null) -join '')
}
function GetHtmlFooter{
    <#
        .SYNOPSIS
            Returns the html footer

        .NOTES
            This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
            The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
            The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
            the use and the consequences of the use of this freely available script.
            PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
            © ScriptRunner Software GmbH
            
        .Parameter Footer  
            Reference parameter for result
    #>

    param(
        [Parameter(Mandatory = $true)]
        [ref]$Footer
    )

$footerHtml = @"
    <script>
        function ToogleProperties(key) {
            const contentDiv = document.getElementById('contentProp' + key);
            const iconSpan = document.getElementById('iconProp' + key);
            contentDiv.style.display = contentDiv.style.display !== 'none' ? "none" : 'block';
            iconSpan.innerHTML = contentDiv.style.display !== 'none' ? "-" : '+';
        }
        function ToogleCases(key) {
            const contentDiv = document.getElementById('contentCase' + key);
            const iconSpan = document.getElementById('iconCase' + key);
            contentDiv.style.display = contentDiv.style.display !== 'none' ? "none" : 'block';
            iconSpan.innerHTML = contentDiv.style.display !== 'none' ? "-" : '+';
        }
    </script>
"@
    $Footer.Value = [System.Environment]::NewLine.ToString() + $footerHtml 
}