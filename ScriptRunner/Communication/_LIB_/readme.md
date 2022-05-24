+ [NotificationLibrary.ps1](./NotificationLibrary.ps1)

With this library we provide some functions to send notifications to different communication channels.<br /> 
Currently, the library includes features for email, Yammer, Teams and Slack.<br /> 
You can learn how to use the individual functions in the documentation:<br />

***Link will follow***

or in short form using the following guides:

#### SRXSendMailTo

You need a SMTP server which allows anonymous authentication or authentication by credentials.<br /> 
If you want to use Exchange Online as SMTP server, you have to configure the SMTP authentication first.<br /> 
Microsoft strongly advises against this:<br /> 
https://docs.microsoft.com/en-us/exchange/clients-and-mobile-in-exchange-online/authenticated-client-smtp-submission

#### SRXPostToTeamsChannel

**Creating the Incoming Webhook**

1. Log in to the Teams app and go to the "Teams" section. The different teams are listed there. Under the teams you will find the corresponding channels.
2. Click with the right mouse button on the channel for which you want to set up a webhook. In the context menu you will find the entry "Connectors" (if you have the appropriate permissions) -> Click on "Connectors".
3. In the following dialog, select the entry "Incoming Webhook" and click on "Configure".
4. In the next step, the incoming webhook must be configured. For this purpose, you assign a suitable name. In our case, the webhook is called "Test Connector". Optionally, a "profile picture" can be assigned, which is displayed with the messages in the channel.
5. Once you have assigned a name and optionally an image, the webhook can be created via "Create".
6. After you click on "Create", the webhook will be created and a URL will be displayed that will be used later in the script.

**Using the Function in a Script**

Invoke the function with the following parameters:

1. *$WebhookURL:* The parameter takes the copied webhook URL to connect against the endpoint.<br />
2. *$Message:* As the name implies, the parameter takes the actual message to be posted later to the channel<br />
3. *$Title:* takes the title of the message<br />
4. *$MessageColor:* This parameter can be used to assign a color to the messages, e.g. red for error messages or green for successfully executed tasks. The values "Red", "Green" and "Orange" are permitted.<br />
5. *$ActivityTitle:* Here you can specify the title for an activity.<br />
6. *$ActivitySubtitle:* A subtitle for the "ActivityTitle". <br />

#### SRXPostToYammer

**Prerequisites**

1. An account/user with permissions to post to Yammer.<br />
2. An Azure AD app with appropriate permissions (for this, a new app can be created or, if ScriptRunner is already used with Azure AD, the ScriptRunner Service App).<br />

**Registering the Azure AD App**

In this tutorial we will set up access via the ScriptRunner Service App. If you want to set up a new app, you can find instructions directly at Microsoft:

[Register an application with the Microsoft identity platform](https://docs.microsoft.com/en-us/azure/active-directory/develop/quickstart-register-app)

Once you have registered a corresponding app, you can follow these instructions again. Except for setting the permissions for Yammer, no further steps are necessary. We will take a look at how this works in the following:

1. Go to portal.azure.com and log in with an administrative user. If you have multiple tenants, find the tenant where you want to register the app. This works via "Directories + subscriptions" in the upper left corner.<br />
2. Switch to the Azure Active Directory and there to "App registrations".<br />
3. Select the "ScriptRunner Service" app there (or the app you registered yourself).<br />
4. Then click on "API permissions" in the left navigation and then on "Add a permission".<br />
5. In the following dialog you select the API permissions for Yammer. At the moment only the option "Delegated permissions" is available. This option + "user_impersonation" form our configuration for the possibility to authenticate via OAuth 2.0.<br />
6. Finally, the permission must be granted. This is done via the "Grant admin consent for ..." option right next to "Add a permission".<br />

**Using the Function in a Script**

Invoke the function with the following parameters:

*$tokenUri:* Takes the URI to query the access token endpoint (e.g. https://login.microsoftonline.com/your-tenant-id/oauth2/v2.0/token)<br />
*$clientId:* Takes the ID of your app  (Client ID).<br />
*$clientSecret:* Takes your client secret.<br />
*$tokenCredential:* Takes a PSCredential object, which should contain the credentials of the user permitted to the Yammer API.<br />
*$grantType:* Takes the grant type to the Yammer API (e.g. "password").<br />
*$scope:* Takes the scope which the app should have to manipulate Yammer data.<br />
*$method:* Takes the method for the web request (POST, GET, DEL and PUT).<br />
*$groupId:* Takes the group ID for the Yammer community/group.<br />
*$yammerMessage:* Takes the message for the Yammer community/group.<br />
*$yammerUri:* Takes the URI for the Yammer endpoint.<br />


#### SRXPostToSlackChannel

**Creating the Incoming Webhook**

1. Go to https://api.slack.com/ and click on "create an app". You will then land on the dashboard of the Slack API website.<br />
2. If you are not signed in yet, you will see the message "You'll need to sign in to your Slack account to create an application" on the dashboard.  Click on the link to sign in to your Slack account.<br />
3. Once you have logged in, you will need to go back to https://api.slack.com/ because the login will redirect you directly to your workspace, or to the page where you need to select your workspace.<br />
4. Back on the dashboard, please select "Create new App".<br />
5. At this point, Slack offers two options to create an app, "From Scratch" and "From an app manifest". In our case, you choose "From scratch".<br />
6. Give your app an appropriate name! For this documentation I named my app "ScriptRunner Webhook". Furthermore you have to choose the appropriate workspace that contains the channels you want to send messages to via ScriptRunner/Webhook.<br />
7. On the next page, there are many choices for the functionality of your new app. In this case, take "Incoming Webhooks".<br />
8. After you have clicked on "Incoming Webhook", you have to activate it. This is done via the slider in the upper right corner. Set this from "Off" to "On".
9. In the next step, a webhook URL must be added to the incoming webhook. This works via the corresponding button "Add New Webhook to Workspace". You will now be redirected to a page where you can select the channel for which the webhook should be <br /> used.  Confirm the selection of the channel with "Allow".
10. Afterwards, the URL to the webhook can be viewed on the configuration page of the webhook, copied and used via script.<br />

**Using the Function in a Script**

Invoke the function with the following parameters:

1. *$WebhookURL:* As the name suggests, the URL copied from 1. must be inserted here.<br />
2. *$Message:* This is the actual message text to be displayed in Slack.<br />

