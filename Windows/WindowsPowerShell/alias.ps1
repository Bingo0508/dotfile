#config
Function pfzf {
    fzf --height 90% --layout reverse --info inline --border --preview 'bat --color=always {}' --preview-window right,60%,border --bind 'ctrl-/:change-preview-window(50%|hidden|)' --color 'fg:#d6d959,fg+:#00ffa7,bg:#000000,preview-bg:#222222,border:#ffffff'
}

Function Compare-Hash {
    param (
        $FILE_1,
        $FILE_2
    )

    $HASH_1 = Get-FileHash $FILE_1 -Algorithm SHA256 | ForEach-Object Hash
    $HASH_2 = Get-FileHash $FILE_2 -Algorithm SHA256 | ForEach-Object Hash
    $HASH_MATCHED = $HASH_1 -eq $HASH_2
    # OR: $HASH_MATCHED = $HASH_1 -eq $HASH_2

    If ($HASH_MATCHED) {
        Write-Host -ForegroundColor Green Hash matched!
    }
    else {
        Write-Host -ForegroundColor Red Hash not matched!
    }
}

Function sub-text {
    param($FILE)
    subl $FILE
}

Function nvimconfig{ cd ~\AppData\Local\nvim }

#Date time
Function DateTime
{
    $s = Get-Date -Format "dddd, MMMM dd, yyyy hh:mm:ss tt"
    Write-Host -ForegroundColor Cyan $s
    Write-Host ""
}
Function date
{
    $s = Get-Date -Format "dddd, MMMM dd, yyyy"
    Write-Host -ForegroundColor Cyan $s
    Write-Host ""
}
Function time
{
    $s = Get-Date -Format "hh:mm:ss tt"
    Write-Host -ForegroundColor Cyan $s
    Write-Host ""
}

Function syncTime {
    if (Get-Command sudo -errorAction SilentlyContinue) {
        Write-Host "Start w32time service"
        sudo net start w32time
	Write-Host "Sync..."
        sudo w32tm /resync
    }
    else {
        Write-Host 'Needing "gsudo" to run this command!'
	Write-Host 'You can install "gsudo" at "https://github.com/gerardog/gsudo"'
    }
}

# back dir
Function b{ cd .. }
# new file
Function touch{ New-Item -Path . -Name $args[0] }
# view choco list
Function chocolist{ choco list --localonly }
#open $profile with nodepad
Function editProfile{ notepad $PROFILE }
#edit alias with notepad
Function editAlias{notepad $env:USERPROFILE\OneDrive\Documents\WindowsPowerShell\alias.ps1}
# --------- npm ---------
Function ni{ npm install $args }
Function nig{ npm install -g $args }
Function nid{ npm install --save-dev $args }
Function ns{ npm start }
Function nt{ npm run test }
Function nb{ npm run build }
Function nd{ npm run dev }
# --------- yarn ---------
Function yi{ yarn install }
Function ys{ yarn start }
Function yt{ yarn test }
Function yb{ yarn build }
# --------- Git, Github ---------
Function gs{ git status }
Function ginit{ git init }
Function gcf{ git clean -f $args }
Function gsh{ git show $args }
Function gl{ git log }  
Function gd{ git diff $args }
Function ga{ git add $args }
Function gcm{ git commit -m $args }
# --------- Neovim ---------
Function vi{ nvim $args }
Function nvimconfig{ cd ~\AppData\Local\nvim; nvim }

#---------- Other-----------
Function lsu{ls.exe -F --color=auto --show-control-chars}
Function e.{explorer .}
