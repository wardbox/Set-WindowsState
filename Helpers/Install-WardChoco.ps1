function Install-WardChoco {
  param(
    # Name of choco package(s)
    [Parameter(Mandatory = $True)]
    [array]
    $Package
  )

  foreach ($Application in $Package) {
    try {
      choco install -y $Application
    } catch {
      Write-Error $error[0]
      exit(1)
    }
  }
}