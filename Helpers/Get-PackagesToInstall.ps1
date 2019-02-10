function Get-PackagesToInstall {
  param(
    # Config location
    [Parameter(Mandatory = $true)]
    [string]
    $ConfigPath
  )

  $Configuration = Get-Content $ConfigPath | ConvertFrom-Json -AsHashtable
  $PackagestoInstall = @()

  foreach ($DeveloperApp in $Configuration.developer_apps) {
    $PackagestoInstall += $DeveloperApp
  }

  foreach ($PersonalApp in $Configuration.personal_apps) {
    $PackagestoInstall += $PersonalApp
  }

  return $PackagestoInstall
}