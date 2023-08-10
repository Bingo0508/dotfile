(@(& 'C:/Users/manht/AppData/Local/Programs/oh-my-posh/bin/oh-my-posh.exe' init powershell --config='C:\Users\manht\AppData\Local\Programs\oh-my-posh\themes\1_shell.omp.json' --print) -join "`n") | Invoke-Expression

Import-Module "~\OneDrive\Documents\WindowsPowerShell\alias.ps1"	
Import-Module PSReadLine 
Set-PSReadLineOption -PredictionSource History
Import-Module z

# Import the Chocolatey Profile that contains the necessary code to enable
# tab-completions to function for `choco`.
# Be aware that if you are missing these lines from your profile, tab completion
# for `choco` will not function.
# See https://ch0.co/tab-completion for details.
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}

