#Requires -Version 5.0
# Requires -Modules Microsoft.PowerApps.Administration.PowerShell
# Requires -Modules Microsoft.PowerApps.PowerShell

function ConnectPowerApps(){
    <#
        .SYNOPSIS
            Open a connection to Microsoft PowerApps

        .DESCRIPTION

        .NOTES
            This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
            The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
            The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
            the use and the consequences of the use of this freely available script.
            PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
            © ScriptRunner Software GmbH

        .COMPONENT
            Requires Module Microsoft.PowerApps.Administration.PowerShell

        .LINK
            https://github.com/scriptrunner/ActionPacks/tree/master/O365/PowerApps/_LIB_

        .Parameter PAFCredential
            Credential object containing the Microsoft PowerApps/Flow user/password
        #>

        [CmdLetBinding()]
        Param(
            [Parameter(Mandatory = $true)]  
            [PSCredential]$PAFCredential
        )

        try{
            if($null -eq (Get-Module -Name 'Microsoft.PowerApps.Administration.PowerShell')){
                Import-Module Microsoft.PowerApps.Administration.PowerShell
            }

            [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                        'Username' = $PAFCredential.UserName
                        'Password' = $PAFCredential.Password
                        }
            
            $null = Add-PowerAppsAccount @cmdArgs                        
        }
        catch{
            throw
        }
        finally{
        }
}

function ConnectPowerApps4Creators(){
    <#
        .SYNOPSIS
            Open a connection to Microsoft PowerApps

        .DESCRIPTION

        .NOTES
            This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
            The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
            The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
            the use and the consequences of the use of this freely available script.
            PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
            © ScriptRunner Software GmbH

        .COMPONENT
            Requires Module Microsoft.PowerApps.PowerShell

        .LINK
            https://github.com/scriptrunner/ActionPacks/tree/master/O365/PowerApps/_LIB_

        .Parameter PAFCredential
            Credential object containing the Microsoft PowerApps/Flow user/password
        #>

        [CmdLetBinding()]
        Param(
            [Parameter(Mandatory = $true)]  
            [PSCredential]$PAFCredential
        )

        try{
            if($null -eq (Get-Module -Name 'Microsoft.PowerApps.PowerShell')){
                Import-Module Microsoft.PowerApps.PowerShell
            }

            [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                        'Username' = $PAFCredential.UserName
                        'Password' = $PAFCredential.Password
                        }
            
            $null = Add-PowerAppsAccount @cmdArgs                        
        }
        catch{
            throw
        }
        finally{
        }
}

function DisconnectPowerApps(){
    <#
        .SYNOPSIS
            Closes the connection to PowerApps/Flow

        .DESCRIPTION

        .NOTES
            This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
            The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
            The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
            the use and the consequences of the use of this freely available script.
            PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
            © ScriptRunner Software GmbH

        .COMPONENT
            Requires Module Microsoft.PowerApps.Administration.PowerShell

        .LINK
            https://github.com/scriptrunner/ActionPacks/tree/master/O365/PowerApps/_LIB_

        #>

        [CmdLetBinding()]
        Param(
        )

        try{
            Remove-PowerAppsAccount -ErrorAction Stop
        }
        catch{
            throw
        }
        finally{
        }
}

function DisconnectPowerApps4Creators(){
    <#
        .SYNOPSIS
            Closes the connection to PowerApps/Flow

        .DESCRIPTION

        .NOTES
            This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
            The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
            The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
            the use and the consequences of the use of this freely available script.
            PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
            © ScriptRunner Software GmbH

        .COMPONENT
            Requires Module Microsoft.PowerApps.PowerShell

        .LINK
            https://github.com/scriptrunner/ActionPacks/tree/master/O365/PowerApps/_LIB_

        #>

        [CmdLetBinding()]
        Param(
        )

        try{
            Remove-PowerAppsAccount -ErrorAction Stop
        }
        catch{
            throw
        }
        finally{
        }
}