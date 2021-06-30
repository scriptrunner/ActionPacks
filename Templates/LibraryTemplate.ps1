#Requires -Version 5.0

function MyFunc(){
    <#
        .SYNOPSIS
            Function sample

        .DESCRIPTION

        .NOTES
            This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
            The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
            The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
            the use and the consequences of the use of this freely available script.
            PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
            © ScriptRunner Software GmbH

        .COMPONENT
            Requires Module XyZ

        .LINK
            https://github.com/scriptrunner/ActionPacks

        .Parameter Para1
            This is paramter 1
        #>

        [CmdLetBinding()]
        Param(            
            [string]$Para1
        )

        try{
        }
        catch{
            throw
        }
        finally{
        }
}