<#
	.SYNOPSIS
	Start an action with parameters using the WebServiceConnector API2.

	.PARAMETER ActionName
	The name (exact name string) of the action to execute.

	.PARAMETER ParamNames
	Optional: List of parameter names required for the action (e.g., "abra","bebra")
	(i.e., the script parameters you want to set).

	.PARAMETER ParamValues
	Optional: List of parameter values (matching the ParamNames list; e.g., "val1","val2")

	.PARAMETER StartedBy
	Optional: Name or email of the end user to run this action for.
	If this parameter is specified, this name will show in the report as Started By,
	and will be set to $SRXEnv.SRXStartedBy for your script. Otherwise the
	WebServiceConnector service account will be used.

	.PARAMETER TargetName
	Optional: Target override - the name (exact displayname string) of the target to use.
	A target override is possible only if the action has no targets configured,
	or if the action requires a selection from a list of given possible targets.

	.PARAMETER Reason
	Optional: String describing the root cause why the action was executed,
	for the report.
#>

Param
(
	[Parameter(Mandatory=$true)]
	[string]$ActionName,
	[string[]]$ParamNames,
	[string[]]$ParamValues,
	[string]$StartedBy = '',
	[string]$TargetName,
	[string]$Reason = ''
)

function Get-ASRJobControl
{
	PARAM(
		[string]$server,
		[int]$id,
		[ref]$jc
	)
	Get-ASRJobControlFromUri -Uri "http://$server/ScriptRunner/JobControl($id)" -jc ([ref]$jc)
}

function Get-ASRJobControlFromUri
{
	PARAM(
		[string]$Uri,
		[ref]$jc
	)
	$json = $null
	$json = Invoke-WebRequest -Uri $Uri -Method Get -UseDefaultCredentials -ContentType application/json -UseBasicParsing
	if (!$json) {
		throw 'Request failed.'
	}
	$list = $json.Content | ConvertFrom-Json
	$jc.Value = $list;
}

# set your ScriptRunner server here; for local loopback connector simply set 'localhost:port_number'
$server='localhost:8091'

"Starting action $ActionName ..."
# commands to start the action with the specified value
$uri = "http://$server/ScriptRunner/api2/StartAction"

# Create a $bodyobj object to build up the JSON body for the web request, e.g. something like this:
####$body = '{"ActionName": "My Remote Action","sr_ValueA":15,"sr_ValueB":5, "StartedBy": "user@azure.org", "Reason":"Why do we do this"}'

$bodyobj = @{}
$bodyobj['ActionName'] = $ActionName
if ($ParamNames) {
	for ($i=0; $i -lt $ParamNames.Length; $i++) {
		$pname = $ParamNames[$i]
		$pvalue = $ParamValues[$i]
		$bodyobj['sr_' + $pname] = $pvalue
	}
}
if ($StartedBy) { $bodyobj['StartedBy'] = $StartedBy }
if ($TargetName) { $bodyobj['TargetName'] = $TargetName }
if ($Reason) { $bodyobj['Reason'] = $Reason }
$bodyobj['WaitTime'] = 0

$body = ''
$body = $bodyobj | ConvertTo-Json
$body

# This is the web request (POST with JSON body data as defined above).
# Sending the request with e.g. CURL.EXE would be very similar!
$json = $null
$json = Invoke-WebRequest -Uri $uri -Body $body -Method Post -UseDefaultCredentials -ContentType 'application/json; charset=utf-8' -UseBasicParsing
if (!$json) {
	throw 'Request failed.'
}

# show the response
'' + $json.RawContentLength + ' Bytes: ' + $json.StatusCode + ' ' + $json.StatusDescription
'...'
if ($json.StatusCode -eq 202) {
	$json.Headers
	$Uri = $json.Headers['Location']
	"Relocating to $Uri ..."
}
elseif ($json.StatusCode -eq 200) {
	$list = $json.Content | ConvertFrom-Json
	# This is the ID of the JobControl instance containing the result
	$jcids = $list.value.ID
	$id = $jcids[0]
	# in case of multiple targets, $jcids is a list.
	"Report ID: $jcids (Count = " + $jcids.Count + ")"
	$Uri = "http://$server/ScriptRunner/JobControl($id)"
}
else {
	throw "Error: Status Code $($json.StatusCode)"
}
# In case of $list.value.Running=True, you would have to poll each JobControl($jcid) for the script to finish:
# GET to URI "http://$server/ScriptRunner/JobControl($jcid)", as in
# Invoke-WebRequest -Uri "http://$server/ScriptRunner/JobControl($jcid)" -Method Get -UseDefaultCredentials -ContentType application/json -UseBasicParsing
'...'
Start-Sleep -Seconds 2
$running = $true
while ($running)
{
	$running = $false
	$jc = $null
	Get-ASRJobControlFromUri -Uri $Uri -jc ([ref]$jc)
	$running = $running -OR $jc.Running
	if ($running) {
		'running...'
		Start-Sleep -Seconds 1
	}
}

# if the job has finished, we can access the result report.
# this is the PowerShell report, in case $jc.Running=False
if ($jc.OutReportString) {
	"Report($Uri):"
	'================================='
	$jc.OutReportString
	'================================='
}
# This is the result message, after $jc.Running=False.
if ($jc.OutResultMessage) {
	"ResultMessage: '" + $jc.OutResultMessage + "'"
}
