# NOTE: If you can't run the script due to the ExecutionPolicy, please run this command as admin
# Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
# Or:
# Set-ExecutionPolicy -ExecutionPolicy ByPass -Scope CurrentUser

<# ================== BEGIN OF DECLARE ================ #>
<# ========== DECLARE ALL NECESSARY DATA HERE ========= #>
# Global variable
$IS_RUNNING_AS_ADMIN = [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544")
$SWITCH_ON = $true
$SWITCH_OFF = $false

# Util functions
function Write-Start {
    param (
        [string]$Message
    )

    Write-Host -ForegroundColor Green $Message
}

function Write-Done {
    param (
        [string]$Message
    )
    
    Write-Host -ForegroundColor Blue $Message
}

function Run_Command_As_Admin {
    param (
        [string]$Command,
        [string]$Name = ""
    )

    Write-Start -Message "-> The `"$name`" progress need admin right! Running new process...`n"
    if ($IS_RUNNING_AS_ADMIN) {
        Write-Host -ForegroundColor Magenta "The process return an output:"
        $Command
        Write-Done -Message "`nThe `"$name`" process done."
        return
    }

    $argument = "-NoLogo -NoProfile -Command `"$Command`" | clip" 
    Start-Process -FilePath "powershell.exe" -Verb RunAs -Wait -ArgumentList $argument
    Write-Host -ForegroundColor Magenta "The process return an output:"
    Get-Clipboard
    Write-Done -Message "The `"$name`" process done."
}

# Disable UAC
function UAC {
    param (
        [bool]$Switch
    )

    $UAC_PATH = "REGISTRY::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System"
    $NAME_UAC = "ConsentPromptBehaviorAdmin"
    $DISABLE_UAC_VALUE = 0
    $DEFAULT_UAC_VALUE = 5
    
    if ($Switch) {
        Write-Start -Message "-- Turning on UAC --"
        $Command = "Set-ItemProperty -Path $UAC_PATH -Name $NAME_UAC -Value $DEFAULT_UAC_VALUE"
        Run_Command_As_Admin -Command $Command -Name "UAC"
        Write-Done -Message "-- Turned on UAC --"
    }
    else {
        Write-Start -Message "-- Turning off UAC --"
        $Command = "Set-ItemProperty -Path $UAC_PATH -Name $NAME_UAC -Value $DISABLE_UAC_VALUE"
        Run_Command_As_Admin -Command $Command -Name "UAC"
        Write-Done -Message "-- Turned on UAC --"
    }
}
<# ========== DECLARE ALL NECESSARY DATA HERE ========= #>
<# ================== END OF DECLARE ================== #>

<# ======== Start the script ======== #>
# Disable UAC
UAC -Switch $SWITCH_OFF


# Enable UAC
UAC -Switch $SWITCH_ON
<# ========= End the script ========= #>