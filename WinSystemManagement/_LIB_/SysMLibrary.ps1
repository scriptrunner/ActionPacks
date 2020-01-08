#Requires -Version 5.0

function RemoveComputerProfile(){
<#
        .SYNOPSIS
            Removes profile on computer

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

        .Parameter CimInstance
            Cim user profile instance

        .Parameter Action
            Action to be performed before remove the profile on computer

        .Parameter ComputerName
            Specifies the computer from which the profile are removed
                
        .Parameter AccessAccount
            Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used

        #>

        [CmdLetBinding()]
        Param( 
            [Parameter(Mandatory = $true)]
            [object]$CimInstance,
            [ValidateSet('None','ZipProfile','Rename')]
            [string]$Action,
            [string]$ComputerName,
            [pscredential]$AccessAccount
        )

        try{
            [string]$profilePath = $CimInstance.LocalPath
            if($Action -eq 'ZipProfile'){
                $archiveName = $profilePath + ".zip"
                if($null -eq $AccessAccount){            
                    Invoke-Command -ComputerName $ComputerName -ScriptBlock{                
                        Compress-Archive -LiteralPath $Using:profilePath -CompressionLevel Optimal -DestinationPath $Using:archiveName -Update -ErrorAction Stop
                    } -ErrorAction Stop
                }
                else{            
                    Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{                
                        Compress-Archive -LiteralPath $Using:profilePath -CompressionLevel Optimal -DestinationPath $Using:archiveName -Update -ErrorAction Stop
                    } -ErrorAction Stop
                }
            }
            elseif($Action -eq 'Rename'){
                $newName = $profilePath + ".old"
                if($null -eq $AccessAccount){            
                    Invoke-Command -ComputerName $ComputerName -ScriptBlock{                
                        Rename-Item -Path $Using:profilePath -NewName $Using:newName -Force -Confirm:$false -ErrorAction Stop
                    } -ErrorAction Stop
                }
                else{            
                    Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{                
                        Rename-Item -Path $Using:profilePath -NewName $Using:newName -Force -Confirm:$false -ErrorAction Stop
                    } -ErrorAction Stop
                }
            }
            $null = Remove-CimInstance -CimSession $Script:Cim -InputObject $usrProfile -Confirm:$false -ErrorAction Stop
        }
        catch{
            throw
        }
        finally{
        }
}
function RemoveServerProfile(){
    <#
        .SYNOPSIS
            Removes profile on server

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

        .Parameter ADUser
            Active Directory user instance

        .Parameter Action
            Action to be performed before remove the profile on server
        #>

        [CmdLetBinding()]
        Param( 
            [Parameter(Mandatory = $true)]
            [object]$ADUser,
            [ValidateSet('None','ZipProfile','Rename')]
            [string]$Action
        )

        try{
            if(([System.String]::IsNullOrWhiteSpace($ADUser.ProfilePath) -eq $false) -and ($Action -ne 'None')){
                [string]$srvProfile = $ADUser.ProfilePath
                if($Action -eq 'ZipProfile'){
                    $null = Compress-Archive -LiteralPath $srvProfile -CompressionLevel Optimal -DestinationPath ($srvProfile + '.zip') -Update -ErrorAction Stop
                }
                elseif($Action -eq 'Rename'){
                    $null = Rename-Item -Path $srvProfile -NewName ($srvProfile + '.old') -Force -Confirm:$false -ErrorAction Stop
                }
                $null = Remove-Item -Path $srvProfile -Force -Confirm:$false -Recurse -ErrorAction Stop
            }
        }
        catch{
            throw
        }
        finally{
        }
}
function RemoveOldProfiles(){
    <#
        .SYNOPSIS
            Removes old profiles on computer

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

        .Parameter CimSession
            Cim instance
                
        .Parameter DaysAgo
            Specifies the days the user has not logged in 

        .Parameter ComputerAction
            Action to be performed before remove the profile on computer

        .Parameter ServerAction
            Action to be performed before remove the profile on server    
            
        .Parameter ComputerName
            Specifies the computer from which the profile are removed
                
        .Parameter AccessAccount
            Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used                
        #>

    [CmdLetBinding()]
    Param( 
        [Parameter(Mandatory = $true)]
        [object]$CimSession,
        [int]$DaysAgo = 180,
        [ValidateSet('None','ZipProfile','Rename')]
        [string]$ComputerAction,
        [ValidateSet('None','ZipProfile','Rename')]
        [string]$ServerAction,
        [string]$ComputerName,
        [pscredential]$AccessAccount       
    )

    try{
        $usrProfiles = Get-CimInstance -CimSession $CimSession -ClassName Win32_UserProfile -ErrorAction Stop | Where-Object{$_.Special -eq $false}
        
        if($null -eq $Global:output){
            $Global:output = @()
        }
        foreach($prof in $usrProfiles){
            if($prof.LastUseTime.Date.ToFileTimeUtc() -lt [System.DateTime]::Today.AddDays(-$DaysAgo).ToFileTimeUtc()){
                $sid = $prof.SID
                $Script:usr = Get-ADUser -Filter{SID -eq $sid} -Properties Name
                if([System.String]::IsNullOrWhiteSpace($usr.Name) -eq $false){
                    # Server action
                    RemoveServerProfile -ADUser $Script:usr -Action $ServerAction
                    # Computer actions
                    RemoveComputerProfile -AccessAccount $AccessAccount -ComputerName $ComputerName -CimInstance $prof -Action $ComputerAction
                    $Global:output += "Profile $($prof.LocalPath) removed"
                }
            }
        }
    }
    catch{
        throw
    }
    finally{
    }
}