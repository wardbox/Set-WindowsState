function Install-WardChoco {
  param(
    # Name(s) of choco package(s)
    [Parameter(Mandatory = $True)]
    [array]
    $Package
  )

  $Date = Get-Date -Format yyyy-MM-dd-HH_MM_ss

  Start-Transcript -Path ".\Logs\InstallRun_$Date.txt" -NoClobber

  foreach ($Application in $Package) {
    try {
      choco install -y $Application --limit-output
    } catch {
      Write-Error $error[0]
    }
  }

  Stop-Transcript

}