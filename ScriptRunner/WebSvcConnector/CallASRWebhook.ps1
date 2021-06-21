<#
    .SYNOPSIS
    Trigger a ScriptRunner Action using the Webhook interface.

    .DESCRIPTION
    Trigger a ScriptRunner Action using the Webhook interface, with a POST request to the
    ScriptRunner Webhook URI of this Action.
    The Action and ScriptRunner endpoint are given either as the ScriptRunner endpoint
    (like 'http://server:port/ScriptRunner/') and Action ID, or as the complete Action Webhook endpoint URI.

    .PARAMETER bodyString
    Arbitrary payload string to be transfered in the body of the POST request.
    To send structured data, like a Hashtable, send it as a JSON string, and decode it in your script
    using ConvertFrom-Json.

    .PARAMETER actionID
    The ID of the ScriptRunner Action to execute.
    You find the ID of an Action in the Admin App, on the first card of the Action Edit Wizard.

    .PARAMETER endpoint
    The ScriptRunner endpoint for the WebService connector, like 'http://server:port/ScriptRunner/' or
    'https://server:port/ScriptRunner/'. The default ScriptRunner port is 8091; the ScriptRunner Apps
    show the UI endpoint they use in the About dialog.
    Note that a different IP port may apply for the WebService Connector, depending on your
    authentication settings (STS endpoint, Basic Auth,...).

    .PARAMETER actionUri
    The complete Webhook URI of the action to execute.
    The Webhook URI for an Action is something like "http://server:port/ScriptRunner/api2/PostWebhook/ID",
    with the proper ScriptRunner endpoint for your WebService Connector (http/https, server, port) 
    and the ID of the Action.
    You find the Webhook URI of an Action in the Admin App, on the first card of the Action Edit Wizard.

    .PARAMETER basicAuthCreds
    Optional: Basic Auth credentials, to use Basic Authentication (on the ScriptRunner STS port).
    Without this parameter, the call will use Windows Integrated Auth for the current user
    (Invoke-WebRequest -UseDefaultCredentials).
#>

[CmdletBinding()]

Param
(
    [Parameter(Position=0)]
    [string]$bodyString = '',
    [Parameter(Mandatory=$true, ParameterSetName="Uri")]
    [string]$actionUri,
    [Parameter(Mandatory=$true, ParameterSetName="ID")]
    [string]$actionID,
    [Parameter(ParameterSetName="ID")]
    [string]$endpoint,
    [pscredential]$basicAuthCreds = $null
)

# You can set your ScriptRunner server here, and run the script with the Action ID, without endpoint parameter.
# For local loopback connector on the ScriptRunner host, simply use 'localhost:port_number'.
# The resulting Webhook URI to start the Action will be something like
#$uri = "http://$defaultserver/ScriptRunner/api2/PostWebhook/$actionID"
$defaultserver = 'localhost:8091'
$defaultendpoint = "http://$defaultserver/ScriptRunner/"

$uri = ''
if ($PSCmdlet.ParameterSetName -eq 'Uri') {
    $uri = $actionUri
}
else {
    if (!$endpoint) { $endpoint = $defaultendpoint }
    if (!$endpoint.EndsWith('/')) { $endpoint += '/' }
    if (!$endpoint.EndsWith('ScriptRunner/')) { $endpoint += 'ScriptRunner/' }
    $uri = $endpoint + "api2/PostWebhook/$actionID"
}

# JSON body example:
#$bodyString = '{ "data": "This is JSON" }'
# ...or construct JSON from a Hashtable:
#$bodyobj = @{}
#$bodyobj['data'] = 'This is JSON'
#$bodyString = $bodyobj | ConvertTo-Json

"Starting action $actionID with $($bodyString.Length) chars of data..."
"   -> POST $uri"
# This is the web request (POST with JSON body data as defined above).
# Sending the request with e.g. CURL.EXE would be very similar!
$json = $null
if ($basicAuthCreds) {
    # Basic Auth, on ScriptRunner STS port
    $basicAuthValue = 'Basic ' + [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes("$($basicAuthCreds.UserName):$($basicAuthCreds.GetNetworkCredential().Password)"))
    $Headers = @{ Authorization = $basicAuthValue }
    $json = Invoke-WebRequest -Uri $uri -Body $bodyString -Method Post -Headers $Headers -ContentType 'application/json; charset=utf-8' -UseBasicParsing
}
else {
    # Windows Integrated Auth
    $json = Invoke-WebRequest -Uri $uri -Body $bodyString -Method Post -UseDefaultCredentials -ContentType 'application/json; charset=utf-8' -UseBasicParsing
}
#$json
if (!$json) {
    throw 'Request failed.'
}

# show the response
'   <- ' + $json.RawContentLength + ' Bytes: ' + $json.StatusCode + ' ' + $json.StatusDescription
if (($json.StatusCode -ge 200) -and ($json.StatusCode -lt 400)) {
    '...Action triggered successfully!'
    ''
    #'Response headers:'
    #$json.Headers | Format-Table
    $res = $json.Headers['Location']
    if ($res) {
        "See $res for the result."
        # The Location header may, depending on the version of the ScriptRunner host, contain an URI like
        # "http://server:port/ScriptRunner/JobControl(ID)", with the ID of the result.
        # Poll this URI until the returned JobControl structure has Running=False, at which point the script has finished.
        # Then the JobControl structure will contain the results along with the script execution report:
        #$json = $null
        #if ($basicAuthCreds) {
        #    $json = Invoke-WebRequest -Uri $res -Method Get -Headers $Headers -ContentType application/json -UseBasicParsing
        #} else {
        #    $json = Invoke-WebRequest -Uri $res -Method Get -UseDefaultCredentials -ContentType application/json -UseBasicParsing
        #}
        #if ($json) { $jc = $json.Content | ConvertFrom-Json }
        #$jc
    }
} 
else {
    $json
}

