# WebSvcConnector
Here you find PowerShell sample code calling into the ScriptRunner WebService Connector. 

The primary intension of this code is to serve as a detailed source of API documentation.
In fact it should be quite easy to implement the same behavior in other scripting languages,
like Perl or Python, e.g. using CURL to send the web requests.

However this code will also come in handy to test your settings during configuration.
In a basic setup you can use the scripts and functions locally on the ScriptRunner host,
using the built-in Loopback WebService Connector instance, but the code is not limited
to local execution, it is only the ScriptRunner endpoint URL that needs more attention 
from remote.

## API Endpoints

The ScriptRunner WebService Connector provides three different endpoint APIs to start an Action:
 - Action OData API, on http[s]://server:port/ScriptRunner/ActionContextItem...
 - Action Webhook API, on http[s]://server:port/ScriptRunner/api2/PostWebhook/$ActionID
 - Azure PowerAutomate API, on http[s]://server:port/ScriptRunner/api2/StartAction

[WebSvcConnector.ps1](./WebSvcConnector.ps1) is a container of three main functions, one for each of these endpoints.
So after you load (dot-source) the script, you have three functions available:

 - Start-AsrWebSvcConnector to call the Action OData API,
 - Start-AsrWebhook to call the Action Webhook API, and 
 - Start-AsrWebSvcConnector2 to call the Azure PowerAutomate API

The functions use Windows Integrated Auth (with the current user) by default, but also provide a
$BasicAuthCreds PSCredential parameter for Basic Authentication. 
For the constructed API URLs to have the correct protocol, host, and port, you specify either
the appropriate ScriptRunner endpoint (like `http://server:port/ScriptRunner/` or 
`https://server:port/ScriptRunner/`; check your ScriptRunner installation to use the correct
settings), or the complete API URL.

Other parameters provide the appropriate data for the respective API.

## Example Scripts

In addition to the [WebSvcConnector.ps1](./WebSvcConnector.ps1) script, there are three scripts, one for each of the 
APIs, that were formerly integrated as sample scripts in your ScriptRunner installation.
For more details about the scripts, functions, and parameters, check the comprehensive 
Powershell help that is integrated into the scripts.

- Action OData API - [CallASRWebSvcConnector.ps1](./CallASRWebSvcConnector.ps1)
- Action Webhook API - [CallASRWebhook.ps1](./CallASRWebhook.ps1)
- Azure PowerAutomate API - [CallASRWebSvcConnector2.ps1](./CallASRWebSvcConnector2.ps1)
