Import-Module "~\OneDrive\Documents\WindowsPowerShell\alias.ps1"
Import-Module PSReadLine 
Set-PSReadLineOption -PredictionSource History

# Config color for Get-ChildItem
$PSStyle.FileInfo.Directory = $PSStyle.Underline + $PSStyle.Bold + $PSStyle.Background.Black + $PSStyle.Foreground.Blue
$PSStyle.FileInfo.Executable = $PSStyle.Bold + $PSStyle.Italic + $PSStyle.Foreground.Red
$PSStyle.FileInfo.SymbolicLink = $PSStyle.Foreground.Green + $PSStyle.Blink

# Config color for PSReadLine
Set-PSReadLineOption -Colors @{
    Command = $PSStyle.Foreground.BrightMagenta
    Comment = $PSStyle.Italic + $PSStyle.Foreground.Yellow
    ContinuationPrompt = $PSStyle.Foreground.BrightMagenta
    Emphasis = $PSStyle.Bold + $PSStyle.Italic + $PSStyle.Underline + $PSStyle.Foreground.Magenta
    Error = $PSStyle.Bold + $PSStyle.Italic + $PSStyle.Foreground.Red
    InlinePrediction = $PSStyle.Italic + $PSStyle.Foreground.Cyan
    Keyword = $PSStyle.Foreground.BrightYellow
    ListPrediction = $PSStyle.Italic + $PSStyle.Underline + $PSStyle.Foreground.Cyan
    ListPredictionSelected = $PSStyle.Italic + $PSStyle.Underline + $PSStyle.Foreground.Cyan
    Member = $PSStyle.Italic + $PSStyle.Foreground.BrightWhite
    Number = $PSStyle.Foreground.White
    Operator = $PSStyle.Foreground.Cyan
    Parameter = $PSStyle.Italic + $PSStyle.Foreground.Magenta
    Selection = $PSStyle.Foreground.Yellow
    String = $PSStyle.Foreground.Blue
    Type = $PSStyle.Foreground.BrightGreen
    Variable =  $PSStyle.bold + $PSStyle.Italic + $PSStyle.Underline + $PSStyle.Foreground.Green
}
