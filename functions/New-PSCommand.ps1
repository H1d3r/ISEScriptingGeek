

Function New-PSCommand {

    [cmdletbinding()]

    Param(
        [Parameter(Mandatory = $True, HelpMessage = "Enter the name of your new command")]
        [ValidateNotNullorEmpty()]
        [string]$Name,
        [ValidateScript( {
                #test if using a hashtable or an [ordered] hash table in v3 or later
                ($_ -is [hashtable]) -OR ($_ -is [System.Collections.Specialized.OrderedDictionary])
            })]

        [Alias("Parameters")]
        [object]$NewParameters,
        [switch]$ShouldProcess,
        [string]$Synopsis,
        [string]$Description,
        [string]$BeginCode,
        [string]$ProcessCode,
        [string]$EndCode,
        [switch]$UseISE
    )

    Write-Verbose "Starting $($myinvocation.mycommand)"
    #add parameters
    $myparams = ""
    $helpparams = ""

    Write-Verbose "Processing parameter names"

    foreach ($k in $newparameters.keys) {
        Write-Verbose "  $k"
        $paramsettings = $NewParameters.item($k)

        #process any remaining elements from the hashtable value
        #@{ParamName="type[]",Mandatory,ValuefromPipeline,ValuefromPipelinebyPropertyName,Position}

        if ($paramsettings.count -gt 1) {
            $paramtype = $paramsettings[0]
            if ($paramsettings[1] -is [object]) {
                $Mandatory = "Mandatory=`${0}," -f $paramsettings[1]
                Write-Verbose $Mandatory
            }
            if ($paramsettings[2] -is [object]) {
                $PipelineValue = "ValueFromPipeline=`${0}," -f $paramsettings[2]
                Write-Verbose $PipelineValue
            }
            if ($paramsettings[3] -is [object]) {
                $PipelineName = "ValueFromPipelineByPropertyName=`${0}" -f $paramsettings[3]
                Write-Verbose $PipelineName
            }
            if ($paramsettings[4] -is [object]) {
                $Position = "Position={0}," -f $paramsettings[4]
                Write-Verbose $Position
            }
        }
        else {
            #the only hash key is the parameter type
            $paramtype = $paramsettings
        }

        $item = "[Parameter({0}{1}{2}{3})]`n" -f $Position, $Mandatory, $PipelineValue, $PipelineName
        $item += "[{0}]`${1}" -f $paramtype, $k
        Write-Verbose "Adding $item to myparams"
        $myparams += "$item, `n"
        $helpparams += ".PARAMETER {0} `n`n" -f $k
        #clear variables but ignore errors for those that don't exist
        Clear-Variable "Position", "Mandatory", "PipelineValue", "PipelineName", "ParamSettings" -ErrorAction SilentlyContinue

    } #foreach hash key

    #get trailing comma and remove it
    $myparams = $myparams.Remove($myparams.lastIndexOf(","))

    Write-Verbose "Building text"
    $text = @"
#requires -version 5.1

Function $name {
<#
.SYNOPSIS
$Synopsis

.DESCRIPTION
$Description

$HelpParams
.EXAMPLE
PS C:\> $Name

.NOTES
Version: 0.1
Author : $env:username

.INPUTS

.OUTPUTS

.LINK
#>

[cmdletbinding(SupportsShouldProcess=`$$ShouldProcess)]

Param (
$MyParams
)

Begin {
    Write-Verbose "Starting `$(`$myinvocation.mycommand)"
    $BeginCode
} #begin

Process {
    $ProcessCode
} #process

End {
    $EndCode
    Write-Verbose "Ending `$(`$myinvocation.mycommand)"
} #end

} #end $name function

"@

    if ($UseISE -and $psise) {
        $newfile = $psise.CurrentPowerShellTab.Files.Add()
        $newfile.Editor.InsertText($Text)
    }
    else {
        $Text
    }

    Write-Verbose "Ending $($myinvocation.mycommand)"

} #end New-PSCommand function
