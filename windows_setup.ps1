# NOTE: If you can't run the script due to the ExecutionPolicy, please run this command as admin
# Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
# Or:
# Set-ExecutionPolicy -ExecutionPolicy ByPass -Scope CurrentUser -Force

Write-Warning -Message "Please check winget carefully before installing!"
pause

<# ================== BEGIN OF DECLARE ================ #>
<# ========== DECLARE ALL NECESSARY DATA HERE ========= #>
$ICONS = @{
    "start" = "[START]";
    "error" = "[ERROR]";
    "warn" = "[WARNING]";
    "done" = "[DONE]";
    "process" = "[PROCESS]";
    "folder" = "[FOLDER]";
    "log" = "[LOG]";
    "update" = "[UPDATE]";
    "setting" = "[SETTING]";
    "install" = "[INSTALL]";
    "on" = "[ON]";
    "off" = "[OFF]";
    "registry" = "[REGISTRY]";
    "config" = "CONFIG";
}
$SEPARATE_LINE = "-----------------------------------------------------------------"

$SCRIPT_NAME = "windows_setup"
$OUTPUT_PATH = "$PSScriptRoot\$SCRIPT_NAME"
$LOG_PATH = "$OUTPUT_PATH\log"
$TEMP_PATH = "$OUTPUT_PATH\temp"
$IS_RUNNING_AS_ADMIN = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

function Invoke-Command-As-Admin {
    [CmdletBinding()]
    param(
        [string]$ProcessName = "",
        [string]$Command
    )
    
    while (Test-Path -Path "$LOG_PATH\$ProcessName.log") {
        $id = Get-Random
        $ProcessName = "$ProcessName-$id"
    }

    New-Temp-Script -FileName $ProcessName -CommandList $Command

    Write-Host -ForegroundColor Red "$($ICONS[`"process`"]) The `"$ProcessName`" process requires admin right! Starting admin process ..." 
    $argument = "-NoLogo -NoProfile -File `"$TEMP_PATH\$ProcessName.ps1`"" 
    Start-Process -FilePath "powershell.exe" -Verb RunAs -Wait -ArgumentList $argument
    Write-Host -ForegroundColor Magenta "-----------------------------"
    Write-Host -ForegroundColor Magenta "The process return an output:"
    Write-Host -ForegroundColor Magenta "-----------------------------"
    $log = Get-Log -File $ProcessName
    Write-Log -Message $log
    Write-Host -ForegroundColor Magenta "-----------------------------"
    Write-Host -ForegroundColor Red "$($ICONS[`"process`"]) The `"$ProcessName`" process done."
}

function Write-Separate-Line {
    Write-Host -ForegroundColor Magenta $SEPARATE_LINE
}
function Write-Start {
    [CmdletBinding()]
    param(
        [string]$Message
    )

    Write-Separate-Line
    Write-Host -ForegroundColor Blue "$($ICONS[`"start`"]) $Message"
}
function Write-Done {
    [CmdletBinding()]
    param(
        [string]$Message,
        [switch]$NoSeparateLine
    )

    Write-Host -ForegroundColor Green "$($ICONS[`"done`"]) $Message"
    if (!$NoSeparateLine) {
        Write-Separate-Line
    }
}
function Write-Log {
    [CmdletBinding()]
    param(
        [string]$Message
    )
    
    $MessageLines = $Message.Split("`n")
    foreach ($line in $MessageLines) {
        Write-Host -ForegroundColor Cyan " `$ $line"
    }
}
function Get-Log {
    [CmdletBinding()]
    param(
        [string]$File
    )
    
    $FileContent = Get-Content "$LOG_PATH\$File.log" -ErrorAction Ignore
    
    Set-Variable SPLIT -Option ReadOnly -Value "**********************"
    Set-Variable START_LOG_POS -Option Constant -Value 2
    Set-Variable STOP_LOG_POS -Option Constant -Value 3
    $count = 0
    $ignore_line = $true # Ignore the first line of log, the line 
                         # is just the information of Start-Transcript command

    $log = ""

    foreach ($line in $FileContent) {
        if ($line -eq $SPLIT) {
            $count += 1
            continue
        }

        if ($count -eq $START_LOG_POS) {
            if (!$ignore_line) {
                $log += "$line`n"
            }
            $ignore_line = $false
        }

        if ($count -eq $STOP_LOG_POS) {
            break
        }
    }

    return $log
}
function New-Folder {
    param (
        [string]$Path,
        [string]$Name
    )

    Write-Start -Message "$($ICONS[`"folder`"]) Creating $Name folder ..."

    if (Test-Path -Path $Path) {
        Write-Warning -Message "$($ICONS[`"warn`"]) Old folder exists! Removing ..."
        Remove-Item -Path $Path -Force -Confirm:$false -Recurse
        Write-Done -Message "$($ICONS[`"folder`"]) Removed!" -NoSeparateLine
    }

    New-Item -ItemType Directory -Path $Path
    Write-Done -Message "$($ICONS[`"folder`"]) Created $Name folder!"
}
function New-Temp-And-Log {
    New-Folder -Path "$OUTPUT_PATH" -Name "output"
    New-Folder -Path "$LOG_PATH" -Name "log"
    New-Folder -Path "$TEMP_PATH" -Name "temp"
}
function New-Temp-Script {
    [CmdletBinding()]
    param (
        [string]$FileName,
        [string]$CommandList
    )

    $Commands = $CommandList.Split(";")
    $FileContent = "Start-Transcript -Path `"$LOG_PATH\$FileName.log`" -Force`n"
    foreach ($Command in $Commands) {
        $Command = $Command.Trim()
        $FileContent += "$Command`n"
    }
    $FileContent += "Stop-Transcript"

    $FileContent | Out-File -FilePath "$TEMP_PATH\$FileName.ps1"
}

function Update-Path {
    Write-Start "$($ICONS[`"update`"]) Refreshing path variable."
    $system_path = [System.Environment]::GetEnvironmentVariable("Path","Machine")
    $user_path = [System.Environment]::GetEnvironmentVariable("Path","User") 
    $env:Path = "$system_path;$user_path"
    Write-Done "$($ICONS[`"update`"]) Path variable refreshed."
}

function Enable-UAC {
    $UAC_PATH = "REGISTRY::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System"
    $NAME_UAC = "ConsentPromptBehaviorAdmin"
    $DEFAULT_UAC_VALUE = 5

    Write-Start -Message "$($ICONS[`"setting`"]) $($ICONS[`"on`"]) Turning on UAC"
    $Command = "Set-ItemProperty -Path $UAC_PATH -Name $NAME_UAC -Value $DEFAULT_UAC_VALUE"
    Invoke-Command-As-Admin -ProcessName "Enable UAC" -Command $Command
    Write-Done -Message "$($ICONS[`"setting`"]) $($ICONS[`"on`"]) Turned on UAC"
}
function Disable-UAC {
    $UAC_PATH = "REGISTRY::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System"
    $NAME_UAC = "ConsentPromptBehaviorAdmin"
    $DISABLE_UAC_VALUE = 0

    Write-Start -Message "$($ICONS[`"setting`"]) $($ICONS[`"on`"]) Turning off UAC"
    $Command = "Set-ItemProperty -Path $UAC_PATH -Name $NAME_UAC -Value $DISABLE_UAC_VALUE"
    Invoke-Command-As-Admin -ProcessName "Disable UAC" -Command $Command
    Write-Done -Message "$($ICONS[`"setting`"]) $($ICONS[`"off`"]) Turned off UAC"
}

function Set-Winget {
    Write-Separate-Line

    Install-Winget-Packages
    Update-Winget-Packages

    Write-Separate-Line
}
function Install-Winget-Packages {
    $ID_LIST = @(
        "IObit.AdvancedSystemCare"
        "IObit.Uninstaller"
        "GitHub.GitHubDesktop"
        "Git.Git"
        "JRSoftware.InnoSetup"
        "Tonec.InternetDownloadManager"
        "Microsoft.PowerToys"
        "Microsoft.WindowsTerminal"
        "JanDeDobbeleer.OhMyPosh"
        "JetBrains.Toolbox"
        "RARLab.WinRAR"
        "chrisant996.Clink"
        "iTop.iTopScreenRecorder"
        "qBittorrent.qBittorrent"
        "sharkdp.fd"
        "gerardog.gsudo"
        "Starship.Starship"
        "Clement.bottom"
        "CodeSector.TeraCopy"
        "Microsoft.PowerShell"
        "GitHub.cli"
        "Microsoft.VisualStudioCode"
        "Oracle.JavaRuntimeEnvironment"
        "Oracle.JDK.20"
        "MSYS2.MSYS2"
        "Kitware.CMake"
        "OpenJS.NodeJS.LTS"
        "Neovim.Neovim"
    )

    foreach ($id in $id_list) {
        Update-Path
        winget install --id $id -s winget -e --accept-package-agreements --force
    }
}
function Update-Winget-Packages {
    winget upgrade --all
}

function Set-Chocolaty {
    Write-Separate-Line

    Install-Chocolaty
    Update-Path # Update path for choco command
    Install-Chocolaty-Packages
    Update-Chocolaty

    Write-Separate-Line
}
function Install-Chocolaty {
    Write-Start -Message "$($ICONS[`"install`"]) Installing Chocolaty ..."
    Invoke-Command-As-Admin -ProcessName "Installing Chocolaty" -Command "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"
    Write-Done -Message "$($ICONS[`"install`"]) Chocolaty installed."
}
function Install-Chocolaty-Packages {
    Write-Start -Message "$($ICONS[`"install`"]) Installing Chocolaty package ..."

    if (Get-Command choco -ErrorAction Ignore) {
        Invoke-Command-As-Admin -ProcessName "Chocolaty package" -Command "choco install bat fzf gdu less ripgrep sigcheck winfetch unzip -y"
    }
    else {
        Write-Error -Message "$($ICONS[`"error`"]) Chocolaty isn't installed! Abort ..."
    }

    Write-Done -Message "$($ICONS[`"install`"]) Chocolaty package installed!"

}
function Update-Chocolaty {
    Write-Start -Message "$($ICONS[`"update`"]) Updating Chocolaty ..."

    if (Get-Command choco -ErrorAction Ignore) {
        Invoke-Command-As-Admin -ProcessName "Updating Chocolaty" -Command "choco upgrade all"
    }
    else {
        Write-Error -Message "$($ICONS[`"error`"]) Chocolaty isn't installed! Abort ..."
    }
    Write-Done -Message "$($ICONS[`"update`"]) Chocolaty updated."
}

function Set-Scoop {
    Write-Separate-Line

    Install-Scoop
    Update-Scoop
    Install-Scoop-Packages
    Update-Scoop

    Write-Separate-Line
}
function Install-Scoop {
    Write-Start -Message "$($ICONS[`"install`"]) Installing Scoop ..."
    
    if (Get-Command scoop -ErrorAction Ignore) {
        Write-Warning -Message "$($ICONS[`"warn`"]) Scoop installed!"
    }
    else {
        Invoke-RestMethod get.scoop.sh | Invoke-Expression
    }

    Write-Done -Message "$($ICONS[`"install`"]) Scoop installed."
}
function Install-Scoop-Packages {
    Write-Start -Message "$($ICONS[`"install`"]) Installing scoop package ..."
    
    if (Get-Command scoop -ErrorAction Ignore) {
        scoop install 7zip curl lazygit which wget
    }
    else {
        Write-Error -Message "$($ICONS[`"error`"]) ERROR: Scoop isn't installed! Aborting ..."
    }

    Write-Done -Message "$($ICONS[`"install`"]) Scoop package installed"
}
function Update-Scoop {
    Write-Start -Message "$($ICONS[`"update`"]) Updating Scoop ..."
    
    if (Get-Command scoop -ErrorAction Ignore) {
        if (Get-Command git -ErrorAction Ignore) {
            scoop install git
        }
        scoop update
    }
    else {
        Write-Error -Message "$($ICONS[`"error`"]) ERROR: Scoop isn't installed! Aborting ..."
    }

    Write-Done -Message "$($ICONS[`"update`"]) Scoop updated."
}

function Set-Up-Config {
    Set-Git
    Set-Neovim
    Set-Global-Node-Modules
    Set-Python-Modules
    Set-Starship
}
function Set-Git {
    Write-Start -Message "$($ICONS[`"config`"]) Config git ..."
    git config --global user.email "manhtran050805@gmail.com"
    git config --global user.name "manhtrancoder"
    git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
    Write-Done -Message "$($ICONS[`"config`"]) Config Git done!"
}

function Set-Neovim {
    Write-Start -Message "Starting clone Neovim config ..."
    git clone --depth 1 https://github.com/AstroNvim/AstroNvim $env:LOCALAPPDATA\nvim
    git clone https://github.com/manhtrancoder/user $env:LOCALAPPDATA\nvim\lua\user
    Write-Done -Message "Cloned Neovim config!"
}
function Set-Global-Node-Modules {
    npm install -g neovim
}
function Set-Python-Modules {
    python -m pip install -U pynvim
}
function Set-PowerShell {
    if (Test-Path "$env:USERPROFILE\OneDrive") {
        # Profile for default PowerShell
        Copy-Item -Path ".\Windows\WindowsPowerShell" -Destination "$env:USERPROFILE\OneDrive\Documents" -Recurse -Force
        
        # Profile for PowerShell v7
        Copy-Item -Path ".\Windows\Powershell" -Destination "$env:USERPROFILE\OneDrive\Documents" -Recurse -Force
    }
    else {
        # Profile for default PowerShell
        Copy-Item -Path ".\Windows\WindowsPowerShell" -Destination "$env:USERPROFILE\Documents" -Recurse -Force
        
        # Profile for PowerShell v7
        Copy-Item -Path ".\Windows\Powershell" -Destination "$env:USERPROFILE\Documents" -Recurse -Force
    }

    # Remove old default PSReadline
    Invoke-Command-As-Admin -ProcessName "Remove old PSReadline" -Command "Remove-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\PSReadLine' -Force -Recurse -Confirm:`$false"
    Invoke-Command-As-Admin -ProcessName "Install PSReadline module" -Command "Install-Module PSReadLine -Force"
    Invoke-Command-As-Admin -ProcessName "Install z module" -Command "Install-Module z -AlowClobber -Force"
}
function Set-Starship {
    if (!(Test-Path "$env:USERPROFILE\.config")) {
        New-Item -ItemType Directory "$env:USERPROFILE\.config" -Force
    }

    if (!(Test-Path "$env:LOCALAPPDATA\clink")) {
        New-Item -ItemType Directory "$env:LOCALAPPDATA\clink" -Force
    }

    Copy-Item -Path ".\Windows\starship.toml" -Destination "$env:USERPROFILE\.config" -Force
    Copy-Item -Path ".\Windows\starship.lua" -Destination "$env:LOCALAPPDATA\clink" -Force
}

<# ========== DECLARE ALL NECESSARY DATA HERE ========= #>
<# ================== END OF DECLARE ================== #>



<# ======== Start the script ======== #>
# This script must be run in user right
if ($IS_RUNNING_AS_ADMIN) {
    Write-Error -Message "Please run this script as user not admin!"
    exit
}

New-Temp-And-Log

Start-Transcript -Path "$OUTPUT_PATH\master.log" -Force # Start logging
Disable-UAC

Set-PowerShell

# Set-Winget
# Set-Chocolaty
# Set-Scoop

Set-Up-Config

Enable-UAC

Stop-Transcript # Stop logging
<# ========= End the script ========= #>
