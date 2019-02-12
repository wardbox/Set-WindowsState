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

try {
  choco -v
} catch {
  Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}

$HelperFunctions = Get-ChildItem -Path .\Helpers -Exclude "New-Json.ps1"

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
    $PackagesToUninstall = Get-PackagesToInstall -ConfigPath $ConfigPath @Type
    Uninstall-WardChoco -Package $PackagesToUninstall
  }
  exit(1)
}

# Go through our config.json and determine what needs to be installed

$PackagesToInstall = Get-PackagesToInstall -ConfigPath $ConfigPath -Dev $Dev -IT $IT -Personal $Personal

if ($PackagesToInstall) {
  Install-WardChoco -Package $PackagesToInstall
}