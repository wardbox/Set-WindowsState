# Install choco
# TODO make sure this confirms with the user later, right now we're in the wild west
try {
  choco -v
} catch {
  Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}

$HelperFunctions = Get-ChildItem -Path .\Helpers

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
$ConfigPath = ./config.json

# Go through our config.json and determine what needs to be installed
$PackagesToInstall = Get-PackagesToInstall -ConfigPath ./config.json