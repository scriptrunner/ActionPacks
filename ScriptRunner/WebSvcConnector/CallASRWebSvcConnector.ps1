<#
    .SYNOPSIS
    Start an action with parameters.

    .PARAMETER ActionName
    The name (exact name string) of the action to execute.

    .PARAMETER ParamNames
    Optional: List of parameter names required for the action (e.g., "abra","bebra")
	(i.e., the script parameters you want to set).

    .PARAMETER ParamValues
    Optional: List of parameter values (matching the ParamNames list; e.g., "val1","val2")

    .PARAMETER TargetName
    Optional: Target override - the name (exact displayname string) of the target to use.
    A target override is possible only if the action has no targets configured, or
    if the action requires a selection from a list of given possible targets.

    .PARAMETER Reason
    Optional: String describing the root cause why the action was executed

    .PARAMETER WaitTime
    Optional: Time (in seconds) to block the server waiting for the script to finish.
	If the response (containing a JobControl in JSON) returns with Running=True, you
	can poll this instance until Running=False; then the instance will contain the
	complete results (report, result message, ...).
#>

Param
(
	[Parameter(Mandatory=$true)]
	[string]$ActionName,
	[string[]]$ParamNames,
	[string[]]$ParamValues,
	[string]$TargetName,
	[string]$Reason = '',
	[int]$WaitTime = 3
)

function Get-ASRJobControl
{
    PARAM(
        [string]$server,
        [int]$id,
        [ref]$jc
    )

    $json = Invoke-WebRequest -Uri "http://$server/ScriptRunner/JobControl($id)" -Method Get -UseDefaultCredentials -ContentType application/json -UseBasicParsing
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
$uri = "http://$server/ScriptRunner/ActionContextItem/StartASRNamedAction"

# Create a $bodyobj object to build up the JSON body for the web request, e.g. something like this:
####$body = '{"ActionName": "My Remote Action","ParamNames":["ValueA", "ValueB"],"ParamValues":["17", "5"], "Options": [], "RunFlags":[]}'

$bodyobj = @{}
$bodyobj['ActionName'] = $ActionName
if ($TargetName) {
	$bodyobj['TargetNames'] = ,$TargetName
}
if ($ParamNames) {
	$bodyobj['ParamNames'] = @($ParamNames)
}
if ($ParamValues) {
	$bodyobj['ParamValues'] = @($ParamValues)
}
$bodyobj['Options'] = '', $Reason
$bodyobj['RunFlags'] = , $WaitTime

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
$list = $json.Content | ConvertFrom-Json
# This is the ID of the JobControl instance containing the result
$jcids = $list.value.ID
# in case of multiple targets, $jcids is a list.
"Report ID: $jcids (Count = " + $jcids.Count + ")"

# In case of $list.value.Running=True, you would have to poll each JobControl($jcid) for the script to finish:
# GET to URI "http://$server/ScriptRunner/JobControl($jcid)", as in
# Invoke-WebRequest -Uri "http://$server/ScriptRunner/JobControl($jcid)" -Method Get -UseDefaultCredentials -ContentType application/json -UseBasicParsing

$jobs = @{}
$running = $true
while ($running)
{
    $running = $false
    foreach ($id in $jcids) {
        $jc = $null
        Get-ASRJobControl -server $server -id $id -jc ([ref]$jc)
        $jobs["$id"] = $jc
        $running = $running -OR $jc.Running
    }
    if ($running) {
        '...'
        Start-Sleep -Seconds 1
    }
}

# if every job has finished, we can access the result reports.
foreach ($id in $jcids) {
    $jc = $jobs["$id"]
    # This is the result message, in case $jc.Running=False.
    if ($jc.OutResultMessage) {
        "$id : '" + $jc.OutResultMessage + "'"
    }
    # this is the PowerShell report, in case $jc.Running=False
    if ($jc.OutReportString) {
        "Report($id):"
        '================================='
        $jc.OutReportString
        '================================='
    }
    '.'
}
