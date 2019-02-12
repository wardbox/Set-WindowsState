# Install choco
# TODO make sure this confirms with the user later, right now we're in the wild west
param (

  # Do developer apps
  [Parameter(Mandatory = $false)]
  [switch]
  $Dev,

  # Do IT apps
  [Parameter(Mandatory = $false)]
  [switch]
  $IT,

  # Do personal apps
  [Parameter(Mandatory = $false)]
  [switch]
  $Personal,

  # Uninstall
  [Parameter(Mandatory = $false)]
  [switch]
  $Uninstall

)

$PackagesToInstall = @(
  "7zip",
  "adobereader",
  "atom",
  "awscli",
  "azure-cli",
  "box",
  "chefdk",
  "cmder",
  "conemu",
  "discord",
  "docker-cli",
  "dotnetcore-sdk",
  "dropbox",
  "everything",
  "fiddler",
  "filezilla",
  "firefox",
  "f.lux",
  "gimp",
  "git",
  "github-desktop",
  "gitkraken",
  "golang",
  "googlechrome",
  "googledrive",
  "greenshot",
  "hyper",
  "kubernetes-cli",
  "malwarebytes",
  "mysql.workbench",
  "nodejs",
  "notepadplusplus",
  "postman",
  "powershell-core",
  "putty",
  "python",
  "python2",
  "rdcman",
  "rsat",
  "ruby",
  "rufus",
  "sharex",
  "skype",
  "slack",
  "sourcetree",
  "spotify",
  "sql-server-management-studio",
  "sublimetext3",
  "steam",
  "sysinternals",
  "terraform",
  "vagrant",
  "virtualbox",
  "visualstudio2017enterprise",
  "vmwareworkstation",
  "vlc",
  "vscode",
  "windirstat",
  "winscp",
  "winrar",
  "wireshark"
  "yarn",
  "zoom"
)

try {
  choco -v
} catch {
  Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}

$HelperFunctions = Get-ChildItem -Path $PSScriptRoot\Helpers -Exclude "New-Json.ps1"

# Import all of our helper functions
foreach ($Helper in $HelperFunctions) {
  try {
    . $Helper.FullName
  } catch {
    Write-Error "Failed importing helper function $Function"
    exit(1)
  }
}

# This is your config.json file which can be anywhere
$ConfigPath = "./config.json"

if ($Uninstall) {
  [ValidateSet("nuke", "selected")]$UserChoice = Read-Host -Prompt "Do you want to uninstall everything or just the selected packages? [nuke] [selected]"
  if ($UserChoice -eq "nuke") {
    Uninstall-WardChoco -Nuke
  } elseif ($UserChoice -eq "selected") {
    Uninstall-WardChoco -Package $PackagesToUninstall
  }
  exit(1)
}

if ($PackagesToInstall) {
  Install-WardChoco -Package $PackagesToInstall

  # I STOLE THIS FROM W4RH4WK:
  # https://github.com/W4RH4WK/Debloat-Windows-10
  # Thank you warhawk I'll buy you a beer if we ever meet bud.
  # adapted from https://blogs.technet.microsoft.com/heyscriptingguy/2013/11/23/using-scheduled-tasks-and-scheduled-jobs-in-powershell/
  $ScheduledJob = @{
    Name               = "Chocolatey Daily Upgrade"
    ScriptBlock        = {choco upgrade all -y}
    Trigger            = New-JobTrigger -Daily -at 2am
    ScheduledJobOption = New-ScheduledJobOption -RunElevated -MultipleInstancePolicy StopExisting -RequireNetwork
  }
  Register-ScheduledJob @ScheduledJob
}