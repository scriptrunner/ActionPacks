''
'This PowerShell script file contains example PowerShell code calling the ScriptRunner WebService Connector.'
''
# For conveniance you can set your ScriptRunner server here, and run the functions without the endpoint parameter.
# The default is localhost:port, using the built-in local loopback connector on the ScriptRunner host.
$defaultserver = 'localhost:8091'
$defaultendpoint = "http://$defaultserver/ScriptRunner/"

'The ScriptRunner WebService Connector provides three different endpoint APIs to start an Action:'
' - Action OData URI, on http[s]://server:port/ScriptRunner/ActionContextItem...'
' - Action Webhook api2 URI, on http[s]://server:port/ScriptRunner/api2/PostWebhook/$ActionID'
' - Azure PowerAutomate api2 URI, on http[s]://server:port/ScriptRunner/api2/StartAction'
''
'Use the Start-AsrWebSvcConnector, Start-AsrWebhook, and Start-AsrWebSvcConnector2 function respectively'
'to give it a try. '
'The built-in endpoint URI http://localhost:8091/ScriptRunner may work on the ScriptRunner host only.'


#################################################################
#################### Action Webhook API ####################
#################################################################

<#
	.SYNOPSIS
	Trigger a ScriptRunner Action using the Webhook API.

	.DESCRIPTION
	Trigger a ScriptRunner Action using the Webhook API, with a POST request to the
	ScriptRunner Webhook URI of this Action.
	The Action and ScriptRunner endpoint are given either as the ScriptRunner endpoint
	(like 'http://server:port/ScriptRunner/') and Action ID, or as the complete Action Webhook URI.

	.PARAMETER BodyString
	Arbitrary payload string to be transfered in the body of the POST request.
	To send structured data, like a Hashtable, send it as a JSON string, and decode it in your script
	using ConvertFrom-Json.

	.PARAMETER ActionID
	The ID of the ScriptRunner Action to execute.
	You find the ID of an Action in the Admin App, on the first card of the Action Edit Wizard.

	.PARAMETER Endpoint
	The ScriptRunner endpoint for the WebService connector, like 'http://server:port/ScriptRunner/' or
	'https://server:port/ScriptRunner/'. The default server:port value is localhost:8091.
	The ScriptRunner Apps show the UI endpoint they use in the About dialog.
	Note that a different IP port may apply for the WebService Connector, depending on your
	authentication settings (STS endpoint, Basic Auth,...).

	.PARAMETER ActionUri
	The complete Webhook URI of the action to execute.
	The Webhook URI for an Action is something like "http://server:port/ScriptRunner/api2/PostWebhook/ID",
	with the proper ScriptRunner endpoint for your WebService Connector (http/https, server, port) 
	and the ID of the Action.
	You find the Webhook URI of an Action in the Admin App, on the first card of the Action Edit Wizard.

	.PARAMETER BasicAuthCreds
	Optional: Basic Auth credentials, to use Basic Authentication (on the ScriptRunner STS port).
	Without this parameter, the call will use Windows Integrated Auth for the current user
	(Invoke-WebRequest -UseDefaultCredentials).
#>

function Start-AsrWebhook {
	[CmdletBinding()]
	Param
	(
		[Parameter(Position=0)]
		[string]$BodyString = '',
		[Parameter(Mandatory=$true, ParameterSetName="Uri")]
		[string]$ActionUri,
		[Parameter(Mandatory=$true, ParameterSetName="ID")]
		[string]$ActionID,
		[Parameter(ParameterSetName="ID")]
		[string]$Endpoint,
		[switch]$waitForResult,
		[PSCredential]$BasicAuthCreds = $null
	)

	$uri = ''
	if ($PSCmdlet.ParameterSetName -eq 'Uri') {
		$uri = $ActionUri
	}
	else {
		$ep = _GetEndpointUri -endpoint $Endpoint
		# The resulting Webhook URI to start the Action will be something like
		#$uri = "http://server:port/ScriptRunner/api2/PostWebhook/$ActionID"
		$uri = $ep + "api2/PostWebhook/$ActionID"
	}
	$Headers = $null
	if ($BasicAuthCreds) {
		_GetBasicAuthHeader -basicAuthCreds $BasicAuthCreds -header ([ref]$Headers)
	}
	$auth = if ($Headers) { 'Basic Auth' } else { 'Windows Integrated' }

	# JSON body example:
	#$BodyString = '{ "data": "This is JSON" }'
	# ...or construct JSON from a Hashtable:
	#$bodyobj = @{}
	#$bodyobj['data'] = 'This is JSON'
	#$BodyString = $bodyobj | ConvertTo-Json

	Write-Host "Starting action $ActionID ($auth)..."
	Write-Host "   -> POST $uri ($($BodyString.Length) chars)"
	# This is the web request (POST with JSON body data as defined above).
	# Sending the request with e.g. CURL.EXE would be very similar!
	$json = $null
	if ($Headers) {
		# Basic Auth
		$json = Invoke-WebRequest -Uri $uri -Body $BodyString -Method Post -Headers $Headers -ContentType 'application/json;charset=utf-8' -UseBasicParsing
	}
	else {
		# Windows Integrated Auth
		$json = Invoke-WebRequest -Uri $uri -Body $BodyString -Method Post -UseDefaultCredentials -ContentType 'application/json;charset=utf-8' -UseBasicParsing
	}
	#$json
	if (!$json) {
		throw 'Start-AsrWebhook request failed.'
	}

	# show the response
	Write-Host ('   <- ' + $json.RawContentLength + ' Bytes: ' + $json.StatusCode + ' ' + $json.StatusDescription)
	if (($json.StatusCode -ge 200) -and ($json.StatusCode -lt 400)) {
		Write-Host '...Action triggered successfully!'
		Write-Host ''
		#'Response headers:'
		#$json.Headers | Format-Table
		$jcuri = $json.Headers['Location']
		# The Location header may, depending on the version of the ScriptRunner host, contain an URI like
		# "http://server:port/ScriptRunner/JobControl(ID)", with the ID of the result.
		if ($jcuri) {
			# Poll this URI until the returned JobControl structure has Running=False, at which point the script has finished.
			# Then the JobControl structure will contain the results along with the script execution report:
			if ($waitForResult.IsPresent) {
				$jc = $null
				_WaitForResultFromUri -Uri $jcuri -basicAuthHeader $Headers -jc ([ref]$jc)
				# if the job has finished, we can access the results.
				_OutputReport -jc $jc -withReport
			} else {
				Write-Host "See $jcuri for the result."
			}
		} 
	} 
	else {
		$json
	}
}


##########################################################
#################### Action OData API ####################
##########################################################

<#
	.SYNOPSIS
	Start a ScriptRunner Action with parameters, using the OData API of the ScriptRunner WebService Connector.

	.DESCRIPTION
	You can start a ScriptRunner Action by Action name or by Action ID. The OData API expects a POST body
	containing JSON data in a specific structure. OData can transport an element ID in the request URI.

	.PARAMETER Endpoint
	Optional: The ScriptRunner endpoint for the WebService connector, like 'http://server:port/ScriptRunner/' or
	'https://server:port/ScriptRunner/'. The default server:port value is localhost:8091.
	The ScriptRunner Apps show the UI endpoint they use in the About dialog.
	Note that a different IP port may apply for the WebService Connector, depending on your
	authentication settings (STS endpoint, Basic Auth,...).

	.PARAMETER BasicAuthCreds
	Optional: Basic Auth credentials, to use Basic Authentication (on the ScriptRunner STS port).
	Without this parameter, the call will use Windows Integrated Auth for the current user
	(Invoke-WebRequest -UseDefaultCredentials).

	.PARAMETER ActionName
	The name (exact name string) of the ScriptRunner Action to execute.

	.PARAMETER ActionID
	The ID of the ScriptRunner Action to execute.
	You find the ID of an Action in the Admin App, on the first card of the Action Edit Wizard.

	.PARAMETER ParamNames
	Optional: List of parameter names required for the action (e.g., "abra","bebra")
	(i.e., the script parameters you want to set).

	.PARAMETER ParamValues
	Optional: List of parameter values (matching the ParamNames list; e.g., "val1","val2")

	.PARAMETER TargetName
	Optional: Target override - the name (exact displayname string) of the Target to use.
	A target override is possible only if the Action has no Targets configured, or
	if the Action requires a selection from a list of given possible Targets.

	.PARAMETER Reason
	Optional: String describing the root cause why the Action was executed

	.PARAMETER WaitTime
	Optional: Time (in seconds) to block the server waiting for the script to finish.
	Use carefully! Alternatively, you can poll ScriptRunner for the results:
	If the response (containing a JobControl in JSON) returns with Running=True, you
	can poll this instance until Running=False; then the instance will contain the
	complete results (report, result message, ...).
#>
function Start-AsrWebSvcConnector {
	[CmdletBinding()]
	Param
	(
		[string]$Endpoint,
		[PSCredential]$BasicAuthCreds = $null,
		[Parameter(Mandatory=$true, ParameterSetName="Name")]
		[string]$ActionName,
		[Parameter(Mandatory=$true, ParameterSetName="ID")]
		[string]$ActionID,
		[string[]]$ParamNames,
		[string[]]$ParamValues,
		[string]$TargetName,
		[string]$Reason = '',
		[int]$WaitTime = 3
	)

	# Compute the endpoint. Default is localhost loopback on port 8091.
	$Endpoint = _GetEndpointUri -endpoint $Endpoint
	$Headers = $null
	if ($BasicAuthCreds) {
		_GetBasicAuthHeader -basicAuthCreds $BasicAuthCreds -header ([ref]$Headers)
	}
	$auth = if ($Headers) { 'Basic Auth' } else { 'Windows Integrated' }

	$bodyobj = @{}
	if ($PSCmdlet.ParameterSetName -eq 'Name') {
		Write-Host "Starting Action '$ActionName' ($auth)..."
		# Action given by name, fixed URI is http[s]://server:port/ScriptRunner/ActionContextItem/StartASRNamedAction
		$uri = $Endpoint + 'ActionContextItem/StartASRNamedAction'
		$bodyobj['ActionName'] = $ActionName
	} else {
		Write-Host "Starting Action $ActionID ($auth)..."
		# Action given by ID, as part of the URI http[s]://server:port/ScriptRunner/ActionContextItem($ActionID)/StartASRAction
		$uri = $Endpoint + "ActionContextItem($ActionID)/StartASRAction"
	}
	
	# Create a $bodyobj object to build up the JSON body for the web request, e.g. something like this:
	####$body = '{"ActionName": "My Remote Action","ParamNames":["ValueA", "ValueB"],"ParamValues":["17", "5"], "Options": [], "RunFlags":[]}'
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
	#$body

	Write-Host "   -> POST $uri ($($body.Length) chars)"
	# This is the web request (POST with JSON body data as defined above).
	# Sending the request with e.g. CURL.EXE would be very similar!
	$json = $null
	if ($Headers) {
		# Basic Auth
		$json = Invoke-WebRequest -Uri $uri -Body $body -Method Post -Headers $Headers -ContentType 'application/json;charset=utf-8' -UseBasicParsing
	}
	else {
		# Windows Integrated Auth
		$json = Invoke-WebRequest -Uri $uri -Body $body -Method Post -UseDefaultCredentials -ContentType 'application/json;charset=utf-8' -UseBasicParsing
	}
	if (!$json) {
		throw 'Start-AsrWebSvcConnector request failed.'
	}

	# show the response
	Write-Host ('   <- ' + $json.RawContentLength + ' Bytes: ' + $json.StatusCode + ' ' + $json.StatusDescription)
	$list = $json.Content | ConvertFrom-Json
	# This is the ID of the JobControl instance containing the result
	$jcids = $list.value.ID
	# in case of multiple targets, $jcids is a list. We just check the first here.
	Write-Host ("Report ID: $jcids (Count=" + $jcids.Count + ")")
	$jcid = $jcids[0]

	# In case of $list.value.Running=True, you would have to poll JobControl($jcid) for the script to finish:
	# GET to URI "http://server:port/ScriptRunner/JobControl($jcid)"
	$jcuri = $Endpoint + "JobControl($jcid)"
	$jc = $null
	_WaitForResultFromUri -Uri $jcuri -basicAuthHeader $Headers -jc ([ref]$jc)
	# if the job has finished, we can access the results.
	_OutputReport -jc $jc -withReport
}


#################################################################
#################### Azure PowerAutomate API ####################
#################################################################

<#
	.SYNOPSIS
	Start an action with parameters using the WebService Connector API2.

	.DESCRIPTION
	This API is similar to the OData API, but is specifically designed to work with Azure PowerAutomate.

	.PARAMETER Endpoint
	Optional: The ScriptRunner endpoint for the WebService connector, like 'http://server:port/ScriptRunner/' or
	'https://server:port/ScriptRunner/'. The default server:port value is localhost:8091.
	The ScriptRunner Apps show the UI endpoint they use in the About dialog.
	Note that a different IP port may apply for the WebService Connector, depending on your
	authentication settings (STS endpoint, Basic Auth,...).

	.PARAMETER BasicAuthCreds
	Optional: Basic Auth credentials, to use Basic Authentication (on the ScriptRunner STS port).
	Without this parameter, the call will use Windows Integrated Auth for the current user
	(Invoke-WebRequest -UseDefaultCredentials).

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
function Start-AsrWebSvcConnector2 {
	[CmdletBinding()]
	Param
	(
		[string]$Endpoint,
		[PSCredential]$BasicAuthCreds = $null,
		[Parameter(Mandatory=$true)]
		[string]$ActionName,
		[string[]]$ParamNames,
		[string[]]$ParamValues,
		[string]$StartedBy = '',
		[string]$TargetName,
		[string]$Reason = ''
	)

	# Compute the endpoint. Default is localhost loopback on port 8091.
	$Endpoint = _GetEndpointUri -endpoint $Endpoint
	$Headers = $null
	if ($BasicAuthCreds) {
		_GetBasicAuthHeader -basicAuthCreds $BasicAuthCreds -header ([ref]$Headers)
	}
	$auth = if ($Headers) { 'Basic Auth' } else { 'Windows Integrated' }

	Write-Host "Starting action $ActionName ($auth)..."
	$uri = $Endpoint + "api2/StartAction"

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
	#$body

	Write-Host "   -> POST $uri ($($body.Length) chars)"
	# This is the web request (POST with JSON body data as defined above).
	# Sending the request with e.g. CURL.EXE would be very similar!
	$json = $null
	if ($Headers) {
		# Basic Auth
		$json = Invoke-WebRequest -Uri $uri -Body $body -Method Post -Headers $Headers -ContentType 'application/json;charset=utf-8' -UseBasicParsing
	}
	else {
		# Windows Integrated Auth
		$json = Invoke-WebRequest -Uri $uri -Body $body -Method Post -UseDefaultCredentials -ContentType 'application/json;charset=utf-8' -UseBasicParsing
	}
	if (!$json) {
		throw 'Start-AsrWebSvcConnector2 request failed.'
	}

	# show the response
	Write-Host ('   <- ' + $json.RawContentLength + ' Bytes: ' + $json.StatusCode + ' ' + $json.StatusDescription)
	if ($json.StatusCode -eq 202) {
		$json.Headers
		$jcuri = $json.Headers['Location']
		Write-Host "Relocating to $jcuri ..."
	}
	elseif ($json.StatusCode -eq 200) {
		$list = $json.Content | ConvertFrom-Json
		# This is the ID of the JobControl instance containing the result
		$jcids = $list.value.ID
		# in case of multiple targets, $jcids is a list. We just check the first here.
		Write-Host ("Report ID: $jcids (Count=" + $jcids.Count + ')')
		$jcid = $jcids[0]
		$jcuri = $Endpoint + "JobControl($jcid)"
	}
	else {
		$json
		throw "Error: Status Code $($json.StatusCode)"
	}

	$jc = $null
	_WaitForResultFromUri -Uri $jcuri -basicAuthHeader $Headers -jc ([ref]$jc)
	# if the job has finished, we can access the result report.
	_OutputReport -jc $jc -withReport
}

##########################################################
#################### Helper Functions ####################
##########################################################


function _GetJobControlFromUri
{
	PARAM (
		[string]$uri,
		$basicAuthHeader = $null,
		[ref]$jc
	)
	$json = $null
	if ($basicAuthHeader) {
		$json = Invoke-WebRequest -Uri $uri -Method Get -Headers $basicAuthHeader -ContentType 'application/json;charset=utf-8' -UseBasicParsing
	} else {
		$json = Invoke-WebRequest -Uri $uri -Method Get -UseDefaultCredentials -ContentType 'application/json;charset=utf-8' -UseBasicParsing
	}
	if (!$json) {
		throw '_GetJobControlFromUri request failed.'
	}
	$list = $json.Content | ConvertFrom-Json
	$jc.Value = $list;
}

# In case of $list.value.Running=True, you would have to poll each JobControl($jcid) for the script to finish:
# GET to URI "http://$server/ScriptRunner/JobControl($jcid)", as in
# Invoke-WebRequest -Uri "http://$server/ScriptRunner/JobControl($jcid)" -Method Get -UseDefaultCredentials -ContentType application/json -UseBasicParsing
function _WaitForResultFromUri
{
	PARAM (
		[string]$uri,
		$basicAuthHeader = $null,
		[ref]$jc
	)
	
	Write-Host "Loading results from $uri :"
	Write-Host 'Loading results...' -NoNewline
	Start-Sleep -Seconds 3
	$running = $true
	while ($running)
	{
		$running = $false
		$tmp = $null
		_GetJobControlFromUri -uri $uri -basicAuthHeader $basicAuthHeader -jc ([ref]$tmp)
		$running = $running -OR $tmp.Running
		if ($running) {
			Write-Host '.' -NoNewline
			Start-Sleep -Seconds 3
		} else {
			Write-Host 'ok'
			$jc.Value = $tmp
		}
	}
}

function _OutputReport
{
	PARAM (
		$jc,
		[switch]$withReport
	)
	$id = $jc.ID
	# this is the PowerShell report, in case $jc.Running=False
	if ($withReport.IsPresent -AND $jc.OutReportString) {
		"Report($id):"
		'================================='
		$jc.OutReportString
		'================================='
	}
	# This is the result message, in case $jc.Running=False.
	if ($jc.OutResultMessage) {
		"ResultMessage: '" + $jc.OutResultMessage + "'"
	}
}

function _GetBasicAuthHeader {
	PARAM (
		[PSCredential]$basicAuthCreds,
		[ref]$header
	)
	if ($basicAuthCreds) {
		# Basic Auth, on ScriptRunner STS port
		$basicAuthValue = 'Basic ' + [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes("$($basicAuthCreds.UserName):$($basicAuthCreds.GetNetworkCredential().Password)"))
		$header.Value = @{ Authorization = $basicAuthValue }
	}
}

function _GetEndpointUri {
	PARAM (
		[string]$endpoint
	)
	$ep = $endpoint
	if (!$ep) { $ep = $defaultendpoint }
	if (!$ep.EndsWith('/')) { $ep += '/' }
	if (!$ep.EndsWith('ScriptRunner/')) { $ep += 'ScriptRunner/' }
	return $ep
}