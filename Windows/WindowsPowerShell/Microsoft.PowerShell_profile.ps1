Import-Module "~\OneDrive\Documents\WindowsPowerShell\alias.ps1"	
Import-Module PSReadLine 
Set-PSReadLineOption -PredictionSource History
Invoke-Expression (& { (zoxide init powershell | Out-String) })
