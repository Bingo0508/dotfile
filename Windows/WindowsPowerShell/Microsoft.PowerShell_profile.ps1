(@(& 'C:/Users/manht/AppData/Local/Programs/oh-my-posh/bin/oh-my-posh.exe' init powershell --config='C:\Users\manht\AppData\Local\Programs\oh-my-posh\themes\1_shell.omp.json' --print) -join "`n") | Invoke-Expression

Import-Module "~\OneDrive\Documents\WindowsPowerShell\alias.ps1"	
Import-Module PSReadLine 
Set-PSReadLineOption -PredictionSource History
Import-Module z