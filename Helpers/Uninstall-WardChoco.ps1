function Uninstall-WardChoco {
  param(
    # Name(s) of choco package(s)
    [Parameter(Mandatory = $False)]
    [array]
    $Package,

    # If you want to install everything chocolatey has installed
    [Parameter(Mandatory = $False)]
    [switch]
    $Nuke
  )

  $Date = Get-Date -Format yyyy-MM-dd-HH_MM_ss

  Start-Transcript -Path ".\Logs\UninstallRun_$Date.txt" -NoClobber

  if ($Nuke) {
    choco uninstall all -y
  } else {
    foreach ($Application in $Package) {
      try {
        choco uninstall -y $Application
      } catch {
        Write-Error $error[0]
      }
    }
  }

  Stop-Transcript
}