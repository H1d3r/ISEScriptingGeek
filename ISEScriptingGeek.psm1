

#dot source the scripts
Get-Childitem $psScriptRoot\functions\*.ps1 |
    Foreach-Object {. $_.FullName}

<#
Add an ISE Menu shortcut to save all open files.
This will only save files that have previously been saved
with a title. Anything that is untitled still needs
to be manually saved first.
#>

$saveall = {
    $psise.CurrentPowerShellTab.files |
        Where-Object {-Not ($_.IsUntitled)} |
        ForEach-Object {
        $_.Save()
    }
}

#a function to display scripting about topics
Function Get-ScriptingHelp {
    Param()
    Get-Help about_Scripting* | Select-Object Name, Synopsis |
        Out-GridView -Title "Select one or more help topics" -OutputMode Multiple |
        ForEach-Object { $_ | Get-Help -ShowWindow}
}

#a function to for parameters for the current script
#using Show-Command
Function Start-MyScript {
    Param([string]$Path = $psise.currentfile.FullPath)
    If (Test-path $Path) {
        Show-Command -Name $path
    }
    else {
        Write-Warning "No file found"
    }

} #end function

#set location to current script location
Function Set-ScriptLocation {
    [cmdletbinding()]
    [alias("sd")]
    Param()

    $path = Split-Path -Path $psISE.CurrentFile.FullPath
    set-location -path $path
    clear-host

}

#create a custom sub menu
$jdhit = $psise.CurrentPowerShellTab.AddOnsMenu.Submenus.Add("ISE Scripting Geek", $null, $null)
#create some child menus for better organization
$Book = $jdhit.Submenus.add("Bookmarks", $Null, $Null)
$convert = $jdhit.Submenus.Add("Convert", $Null, $null)
$dates = $jdhit.submenus.Add("Dates and Times", $Null, $Null)
$files = $jdhit.Submenus.Add("Files", $Null, $null)
$work = $jdhit.submenus.Add("Work", $Null, $null)

#add my menu addons in sort of alphabetical order
[void]$jdhit.submenus.Add("Add Help", {New-CommentHelp}, "ALT+H")

[void]$convert.submenus.Add("Convert All Aliases", {ConvertTo-Definition $psise.CurrentFile.Editor.SelectedText}, $Null)
[void]$convert.submenus.Add("Convert Help to Comment Help", {ConvertTo-CommentHelp}, "Ctrl+Shift+H")

[void]$convert.submenus.Add("Convert Code to Snippet", {Convert-CodetoSnippet -Text $psise.CurrentFile.Editor.SelectedText}, "CTRL+ALT+S")

[void]$convert.submenus.Add("Convert Selected to Region", {
        $psise.CurrentFile.Editor.InsertText("#region`r`r$($psise.CurrentFile.Editor.SelectedText)`r`r#endregion")}, $null)
[void]$convert.submenus.Add("Convert Selected From Alias", {ConvertFrom-Alias}, $Null)
[void]$convert.submenus.Add("Convert Single Selected to Alias", {Convert-AliasDefinition $psise.CurrentFile.Editor.SelectedText -ToAlias}, $Null)
[void]$convert.submenus.Add("Convert Single Selected to Command", {Convert-AliasDefinition $psise.CurrentFile.Editor.SelectedText -ToDefinition}, $Null)
[void]$convert.Submenus.Add("Convert to lowercase",
     {$psise.currentfile.editor.insertText($psise.CurrentFile.Editor.SelectedText.toLower())}, "CTRL+ALT+L")
[void]$convert.Submenus.Add("Convert to parameter hash", {Convert-CommandToHash}, "Ctrl+ALT+H")
[void]$convert.submenus.Add("Convert to text file", {ConvertTo-TextFile}, "ALT+T")
[void]$convert.Submenus.Add("Convert to uppercase", {$psise.currentfile.editor.insertText($psise.CurrentFile.Editor.SelectedText.toUpper())}, "CTRL+ALT+U")

[void]$jdhit.Submenus.add("Create new DSC Resource Snippets", {Get-DSCResource | New-DSCResourceSnippet}, $Null)
[void]$jdhit.submenus.add("Edit your ISE profile", {
        If (Test-Path $Profile) {
            Open-EditorFile $profile
        }
        else {
            write-warning "Cannot find $profile"
        }
    }, $Null)
[void]$convert.Submenus.Add("Convert to block comment", {ConvertTo-MultiLineComment}, "Ctrl+Alt+B")

[void]$convert.Submenus.Add("Convert from block comment", {ConvertFrom-MultiLineComment}, "Ctrl+Alt+C")

[void]$files.Submenus.Add("Close All Files", {CloseAllFiles}, "Ctrl+Alt+F4")
[void]$files.Submenus.Add("Close All Files Except Active", {CloseAllFilesButCurrent}, "Ctrl+Shift+F4")

[void]$files.submenus.Add("Edit snippets", {Edit-Snippet}, $Null)

[void]$files.submenus.Add("Get Script Profile", {Get-ASTProfile}, $Null)

[void]$jdhit.submenus.Add("Get Scripting Help", {Get-ScriptingHelp}, $Null)

[void]$files.Submenus.add("Find in File", {Find-InFile}, "Ctrl+Shift+F")
[void]$files.Submenus.Add("New File", {New-FileHere}, "Ctrl+Alt+N")

[void]$dates.submenus.Add("Insert Datetime", {$psise.CurrentFile.Editor.InsertText(("{0} {1}" -f (get-date), (get-wmiobject win32_timezone -property StandardName).standardName))}, "ALT+F5")
[void]$dates.submenus.Add("Insert Short Date", {$psISE.currentfile.editor.inserttext((Get-Date).ToShortDateString())}, "ALT+F6")
[void]$dates.submenus.Add("Insert Short Time", {$psISE.currentfile.editor.inserttext((Get-Date).ToShortTimeString())}, "ALT+F7")
[void]$dates.submenus.Add("Insert Short Date Time", {$psISE.currentfile.editor.inserttext((Get-Date -Format g))}, "ALT+F8")
[void]$dates.submenus.Add("Insert Long Date", {$psISE.currentfile.editor.inserttext((Get-Date -displayhint Date))}, "ALT+F9")
[void]$dates.submenus.Add("Insert UTC Date", {$psISE.currentfile.editor.inserttext((Get-Date -format u))}, "ALT+F10")
[void]$dates.submenus.Add("Insert GMT Date", {$psISE.currentfile.editor.inserttext((Get-Date -format r))}, "ALT+F11")


[void]$jdhit.Submenus.add("New CIM Command", {New-CimCommand}, $Null)
[void]$files.submenus.Add("Open Current Script Folder", {Invoke-Item (split-path $psise.CurrentFile.fullpath)}, "ALT+O")
[void]$files.Submenus.Add("Open Selected File", {Open-SelectedISE}, "Ctrl+Alt+F")
[void]$files.Submenus.Add("Reload Selected File", {Reset-ISEFile}, "Ctrl+Alt+R")

[void]$jdhit.submenus.Add("Print Script", {Send-ToPrinter}, "CTRL+ALT+P")
[void]$jdhit.submenus.Add("Run Script", {Start-MyScript}, "CTRL+SHIFT+Z")

[void]$files.Submenus.Add("Save All Files", $saveall, "Ctrl+Shift+A")
[void]$files.submenus.Add("Save File as ASCII", {$psISE.CurrentFile.Save([Text.Encoding]::ASCII)}, $null)

[void]$jdhit.Submenus.Add("Search selected text with Bing", {Get-SearchResult -SearchEngine Bing}, "Shift+Alt+B")
[void]$jdhit.Submenus.Add("Search selected text with Google", {Get-SearchResult -SearchEngine Google}, "Shift+Alt+G")
[void]$jdhit.Submenus.Add("Send to Word", {Copy-ToWord}, "Ctrl+Alt+W")
[void]$jdhit.Submenus.Add("Send to Word Colorized", {Copy-ToWord -Colorized}, $Null) #
[void]$jdhit.submenus.Add("Sign Script", {Write-Signature}, $null)

[void]$jdhit.Submenus.Add("Switch next tab", {Get-NextISETab}, "Ctrl+ALT+T")

[void]$jdhit.Submenus.Add("Use local help", {$psise.Options.UseLocalHelp = $True}, $Null)
[void]$jdhit.Submenus.Add("Use online help", {$psise.Options.UseLocalHelp = $False}, $Null)

[void]$book.Submenus.Add("Add ISE Bookmark", {Add-ISEBookmark}, "Ctrl+Shift+N")
[void]$book.Submenus.Add("Clear ISE Bookmarks", {Remove-Item $MyBookmarks}, "Ctrl+Shift+C")
[void]$book.Submenus.Add("Get ISE Bookmark", {Get-ISEBookmark}, "Ctrl+Shift+G")
[void]$book.Submenus.Add("Open ISE Bookmark", {Open-ISEBookmark}, "Ctrl+Shift+O")
[void]$book.Submenus.Add("Remove ISE Bookmark", {Remove-ISEBookmark}, "Ctrl+Shift+K")
[void]$book.Submenus.Add("Update ISE Bookmark", {Update-ISEBookmark}, "Ctrl+Shift+X")

[void]$work.submenus.Add("Add current file to work", {Add-CurrentProject -List $currentProjectList}, "CTRL+Alt+A")
[void]$work.submenus.Add("Edit current work file", {Edit-CurrentProject -List $currentProjectList}, "CTRL+Alt+E")
[void]$work.submenus.Add("Open current work files", {Import-CurrentProject -List $currentProjectList}, "CTRL+Alt+I")


#define some ISE specific variables
$MySnippets = "$Env:USERPROFILE\Documents\WindowsPowerShell\Snippets"
$MyModules = Join-Path -Path $env:userprofile -ChildPath "documents\WindowsPowerShell\Modules"
$MyPowerShell = "$env:userprofile\Documents\WindowsPowerShell"
$MyBookmarks = Join-Path -path $myPowerShell -ChildPath "myISEBookmarks.csv"
$CurrentProjectList = Join-Path -Path $env:USERPROFILE\Documents\WindowsPowerShell -ChildPath "currentWork.txt"

Export-ModuleMember -Variable 'MySnippets','MyModules','MyPowerShell','MyBookmarks','CurrentProjectList' -alias 'ccs', 'gcmd', 'glcm''tab', 'sd'

