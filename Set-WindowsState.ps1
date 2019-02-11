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
  $Personal

)

if ($Dev -or $IT -or $Personal) {
  $Type = @{
    Dev      = $false
    IT       = $false
    Personal = $false
  }
}

if ($Dev) {
  $Type.Dev = $true
}

if ($IT) {
  $Type.IT = $true
}

if ($Personal) {
  $Type.Personal = $true
}

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
    Write-Error "Fuuuck, failed importing helper function $Function"
    exit(1)
  }
}

# This is your config.json file which can be anywhere
$ConfigPath = "./config.json"

# Go through our config.json and determine what needs to be installed
if ($Type) {
  $PackagesToInstall = Get-PackagesToInstall -ConfigPath $ConfigPath @Type
} else {
  Write-Error "No types identified"
  exit(1)
}

if ($PackagesToInstall) {
  Install-WardChoco -Package $PackagesToInstall
}