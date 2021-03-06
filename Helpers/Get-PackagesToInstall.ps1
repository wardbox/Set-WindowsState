function Get-PackagesToInstall {
  param(
    # Config location
    [Parameter(Mandatory)]
    [string]
    $ConfigPath,

    # Do developer apps
    [Parameter(Mandatory = $false)]
    $Dev,

    # Do IT apps
    [Parameter(Mandatory = $false)]
    $IT,

    # Do personal apps
    [Parameter(Mandatory = $false)]
    $Personal

  )

  if (!($Dev -or $IT -or $Personal)) {
    Write-Error "You must declare at least one of the switches - (Dev, IT, or Personal)"
    exit(1)
  }

  $Configuration = Get-Content $ConfigPath | ConvertFrom-Json
  $PackagestoInstall = @()

  if ($Dev) {
    foreach ($DeveloperApp in $Configuration.developer_apps) {
      $PackagestoInstall += $DeveloperApp
    }
  }

  if ($IT) {
    foreach ($ItApp in $Configuration.it_apps) {
      $PackagestoInstall += $ItApp
    }
  }

  if ($Personal) {
    foreach ($PersonalApp in $Configuration.personal_apps) {
      $PackagestoInstall += $PersonalApp
    }
  }

  return $PackagestoInstall

}