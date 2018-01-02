function Write-Activity {

    <#
    .SYNOPSIS
    Display an activity
    .DESCRIPTION
    Display the activity to the console and output to a log file, this is done to uniform the output for long scripts\tasks
    .PARAMETER Message
    Input a message in a string format to display onscreen and to the log file.
    For any content that needs to be highlighted surround that text with ";"
    .PARAMETER TextColor
    Input a color for the text that is not highlighted
    Default is White
    .PARAMETER Highlight
    Input a color for the text that IS highlighted
    Default is Cyan
    .PARAMETER Log
    Input the path to output the log to
    .PARAMETER Level
    Input the level of the task, used to define sub tasks within a task
    Default is 0 for the parent task
    .PARAMETER NewLine
    Input whether a new line is required after displaying to the console.
    This is required when a task is to be broken down into smaller tasks
    .NOTES
    Version: 1.0
    Author: Tim Rogers
    Creation Date: 1/1/2018
    Purpose/Change: Re-use in scripts
    .EXAMPLE
    Run the Write-Activity Function to display a message as a main task:
    Write-Activity -Message "Checking ;date" -NewLine -log $log
    .EXAMPLE
    Run the Write-Activity Function to display a message as a subtask:
    Write-Activity -Message "The date today is [;$(Get-Date);] and in one week it will be [;$((Get-Date).AddDays(7));]" -Level 1 -Log $log
    #>

    Param ([Parameter(Mandatory=$true)][string]$Message, [string]$TextColor="White", [string]$Highlight="Cyan",[Parameter(Mandatory=$true)][string]$Log, [int]$Level=0,[switch]$NewLine)
    
    #Indent
    If($Level -ne 0){
        Do{
            Write-Host "-" -NoNewline -ForegroundColor $TextColor
            $MsgConstruction += "-"
            $Level --
        }Until($Level -eq 0)
    }
    ElseIf($Level -eq 0){$MsgConstruction = "$(Get-Date -Format U) - "}
    
    #Write to console
    $MsgArray = {$Message.split(";")}.Invoke()
    $count = $MsgArray.count
    $color = $TextColor
    Do{
        Write-Host $MsgArray[0] -NoNewline -ForegroundColor $Color
        $MsgArray.remove($MsgArray[0]) | out-null
        If($Color -eq $TextColor){$Color = $Highlight}Elseif($Color -eq $Highlight){$Color = $TextColor}
        $count --
    }Until($count -eq 0)
    Write-Host "..." -NoNewline -ForegroundColor $TextColor
    If($NewLine){Write-Host ""}

    #Write to log
    $MsgConstruction += $Message.replace(";","")
    Add-Content $Log $MsgConstruction
    
}

function Write-Result {
<#
    .SYNOPSIS
    Display a result
    .DESCRIPTION

    Display the results to the console (optional) and output to a log file.

    .PARAMETER LogMessage
    Input a message in a string format to output to the log file.
    .PARAMETER Log
    Input the path to output the log to
    .PARAMETER Level
    Input the level of the task, used to define sub tasks within a task
    Default is 0 for the parent task
    .PARAMETER Pass
    Mark the result as a pass.
    A custom Pass message can be defined using -ConsolePassMsg, otherwise Default is "Done!"
    .PARAMETER ConsolePassMsg
    Enter a custom pass message, Default is "Done!"
    .PARAMETER Error
    Mark the result as a fail
    A custom Error message can be defined using -ConsoleErrorMsg, otherwise Default is "Failed!"
    .PARAMETER ConsoleErrorMsg
    Enter a custom error message, Default is "Failed!"
    .PARAMETER ReturnedErrorMsg
    Enter returned error message $_
    .PARAMETER Warning
    Mark the result with a warning
    .PARAMETER ConsoleWarningMsg
    Enter a custom warning message. There is no default
    .PARAMETER NoConsoleOutput
    Output results only to log file

    .NOTES
    Version: 1.0
    Author: Tim Rogers
    Creation Date: 1/1/2018
    Purpose/Change: Re-use in scripts
    .EXAMPLE 
        Run the Write-Result Function to display a passed result and output to log
        Write-Result -LogMessage "Found the correct day" -Log $log -Pass -ConsolePassMsg "Day Found!"
    .EXAMPLE
        Run the Write-Result Function to display an error message and output errors to log:
        $Computer = "DUKNT90318uka"
        Try{Get-ADComputer $Computer}
        Catch{Write-Result -LogMessage "Unable to locate $computer in AD" -Log $log -Error -ConsoleErrorMsg "Failed to find computer" -ReturnedErrorMsg $_}
    #>

    Param ([Parameter(Mandatory=$true)][string]$LogMessage,[Parameter(Mandatory=$true)][string]$Log,[int]$Level=0,
           [Parameter(ParameterSetName="Pass",Mandatory=$False)][Switch]$Pass,[Parameter(ParameterSetName="Pass",Mandatory=$false)][string]$ConsolePassMsg="Done!",
           [Parameter(ParameterSetName="Error",Mandatory=$False)][Switch]$Error,[Parameter(ParameterSetName="Error",Mandatory=$false)][string]$ConsoleErrorMsg="Failed!",[Parameter(ParameterSetName="Error",Mandatory=$False)][System.Management.Automation.ErrorRecord]$ReturnedErrorMsg,
           [Parameter(ParameterSetName="Warning",Mandatory=$False)][Switch]$Warning,[Parameter(ParameterSetName="Warning",Mandatory=$true)][string]$ConsoleWarningMsg,
           [Parameter(ParameterSetName="NoConsoleOutput",Mandatory=$False)][Switch]$NoConsoleOutput
           )
    
    #Indent
    If($Level -ne 0){
        Do{
            $MsgConstruction += "-"
            $Level --
        }Until($Level -eq 0)
    }
    If($Error){$MsgConstruction += "ERROR: "}
    Elseif($Warning){$MsgConstruction += "WARNING: "}
    #Alter result output
    If($Error){
        $ResultColor = "Red"
        $CustomResultMsg = $ConsoleErrorMsg
    }
    ElseIf($Warning){
        $ResultColor = "Yellow"
        $CustomResultMsg = "WARNING!: $ConsoleWarningMsg"
    }
    Elseif($Pass){
        $ResultColor = "Green"
        $CustomResultMsg = $ConsolePassMsg
    }
    Else{
        $ResultColor = "Gray"
        $CustomResultMsg = "No result submitted"
    }
    #Write to console
    If(!$NoConsoleOutput){Write-Host $CustomResultMsg -ForegroundColor $ResultColor}
    #Write to log
    Add-Content $Log "$MsgConstruction $LogMessage"
    If($ReturnedErrorMsg){Add-Content $Log "$MsgConstruction $($_.ToString())"}
}
