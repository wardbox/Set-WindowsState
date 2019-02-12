# I STOLE THIS FROM W4RH4WK:
# https://github.com/W4RH4WK/Debloat-Windows-10
# Thank you warhawk I'll buy you a beer if we ever meet bud.

#   Description:
# This script removes unwanted Apps that come with Windows. If you  do not want
# to remove certain Apps comment out the corresponding lines below.

# Thanks to raydric, this function should be used instead of `mkdir -force`.
#
# While `mkdir -force` works fine when dealing with regular folders, it behaves
# strange when using it at registry level. If the target registry key is
# already present, all values within that key are purged.

function force-mkdir($path) {
  if (!(Test-Path $path)) {
    #Write-Host "-- Creating full path to: " $path -ForegroundColor White -BackgroundColor DarkGreen
    New-Item -ItemType Directory -Force -Path $path
  }
}

function Takeown-Registry($key) {
  # TODO does not work for all root keys yet
  switch ($key.split('\')[0]) {
      "HKEY_CLASSES_ROOT" {
          $reg = [Microsoft.Win32.Registry]::ClassesRoot
          $key = $key.substring(18)
      }
      "HKEY_CURRENT_USER" {
          $reg = [Microsoft.Win32.Registry]::CurrentUser
          $key = $key.substring(18)
      }
      "HKEY_LOCAL_MACHINE" {
          $reg = [Microsoft.Win32.Registry]::LocalMachine
          $key = $key.substring(19)
      }
  }

  # get administraor group
  $admins = New-Object System.Security.Principal.SecurityIdentifier("S-1-5-32-544")
  $admins = $admins.Translate([System.Security.Principal.NTAccount])

  # set owner
  $key = $reg.OpenSubKey($key, "ReadWriteSubTree", "TakeOwnership")
  $acl = $key.GetAccessControl()
  $acl.SetOwner($admins)
  $key.SetAccessControl($acl)

  # set FullControl
  $acl = $key.GetAccessControl()
  $rule = New-Object System.Security.AccessControl.RegistryAccessRule($admins, "FullControl", "Allow")
  $acl.SetAccessRule($rule)
  $key.SetAccessControl($acl)
}

function Takeown-File($path) {
  takeown.exe /A /F $path
  $acl = Get-Acl $path

  # get administraor group
  $admins = New-Object System.Security.Principal.SecurityIdentifier("S-1-5-32-544")
  $admins = $admins.Translate([System.Security.Principal.NTAccount])

  # add NT Authority\SYSTEM
  $rule = New-Object System.Security.AccessControl.FileSystemAccessRule($admins, "FullControl", "None", "None", "Allow")
  $acl.AddAccessRule($rule)

  Set-Acl -Path $path -AclObject $acl
}

function Takeown-Folder($path) {
  Takeown-File $path
  foreach ($item in Get-ChildItem $path) {
      if (Test-Path $item -PathType Container) {
          Takeown-Folder $item.FullName
      } else {
          Takeown-File $item.FullName
      }
  }
}

function Elevate-Privileges {
  param($Privilege)
  $Definition = @"
  using System;
  using System.Runtime.InteropServices;
  public class AdjPriv {
      [DllImport("advapi32.dll", ExactSpelling = true, SetLastError = true)]
          internal static extern bool AdjustTokenPrivileges(IntPtr htok, bool disall, ref TokPriv1Luid newst, int len, IntPtr prev, IntPtr rele);
      [DllImport("advapi32.dll", ExactSpelling = true, SetLastError = true)]
          internal static extern bool OpenProcessToken(IntPtr h, int acc, ref IntPtr phtok);
      [DllImport("advapi32.dll", SetLastError = true)]
          internal static extern bool LookupPrivilegeValue(string host, string name, ref long pluid);
      [StructLayout(LayoutKind.Sequential, Pack = 1)]
          internal struct TokPriv1Luid {
              public int Count;
              public long Luid;
              public int Attr;
          }
      internal const int SE_PRIVILEGE_ENABLED = 0x00000002;
      internal const int TOKEN_QUERY = 0x00000008;
      internal const int TOKEN_ADJUST_PRIVILEGES = 0x00000020;
      public static bool EnablePrivilege(long processHandle, string privilege) {
          bool retVal;
          TokPriv1Luid tp;
          IntPtr hproc = new IntPtr(processHandle);
          IntPtr htok = IntPtr.Zero;
          retVal = OpenProcessToken(hproc, TOKEN_ADJUST_PRIVILEGES | TOKEN_QUERY, ref htok);
          tp.Count = 1;
          tp.Luid = 0;
          tp.Attr = SE_PRIVILEGE_ENABLED;
          retVal = LookupPrivilegeValue(null, privilege, ref tp.Luid);
          retVal = AdjustTokenPrivileges(htok, false, ref tp, 0, IntPtr.Zero, IntPtr.Zero);
          return retVal;
      }
  }
"@
  $ProcessHandle = (Get-Process -id $pid).Handle
  $type = Add-Type $definition -PassThru
  $type[0]::EnablePrivilege($processHandle, $Privilege)
}

function Remove-DefaultApps {
  Write-Output "Elevating privileges for this process"
  do {} until (Elevate-Privileges SeTakeOwnershipPrivilege)

  Write-Output "Uninstalling default apps"
  $apps = @(
    # default Windows 10 apps
    "Microsoft.3DBuilder"
    "Microsoft.Appconnector"
    "Microsoft.Advertising.Xaml"
    "Microsoft.BingFinance"
    "Microsoft.BingNews"
    "Microsoft.BingSports"
    "Microsoft.BingTranslator"
    "Microsoft.BingWeather"
    #"Microsoft.FreshPaint"
    "Microsoft.Microsoft3DViewer"
    "Microsoft.MicrosoftOfficeHub"
    "Microsoft.MicrosoftSolitaireCollection"
    "Microsoft.MicrosoftPowerBIForWindows"
    "Microsoft.MinecraftUWP"
    #"Microsoft.MicrosoftStickyNotes"
    "Microsoft.NetworkSpeedTest"
    "Microsoft.Office.OneNote"
    #"Microsoft.OneConnect"
    "Microsoft.People"
    "Microsoft.Print3D"
    "Microsoft.SkypeApp"
    "Microsoft.Wallet"
    #"Microsoft.Windows.Photos"
    "Microsoft.WindowsAlarms"
    #"Microsoft.WindowsCalculator"
    "Microsoft.WindowsCamera"
    "microsoft.windowscommunicationsapps"
    "Microsoft.WindowsMaps"
    "Microsoft.WindowsPhone"
    "Microsoft.WindowsSoundRecorder"
    #"Microsoft.WindowsStore"
    "Microsoft.XboxApp"
    "Microsoft.XboxGameOverlay"
    "Microsoft.XboxGamingOverlay"
    "Microsoft.XboxSpeechToTextOverlay"
    "Microsoft.Xbox.TCUI"
    "Microsoft.ZuneMusic"
    "Microsoft.ZuneVideo"


    # Threshold 2 apps
    "Microsoft.CommsPhone"
    "Microsoft.ConnectivityStore"
    "Microsoft.GetHelp"
    "Microsoft.Getstarted"
    "Microsoft.Messaging"
    "Microsoft.Office.Sway"
    "Microsoft.OneConnect"
    "Microsoft.WindowsFeedbackHub"

    # Creators Update apps
    "Microsoft.Microsoft3DViewer"
    #"Microsoft.MSPaint"

    #Redstone apps
    "Microsoft.BingFoodAndDrink"
    "Microsoft.BingTravel"
    "Microsoft.BingHealthAndFitness"
    "Microsoft.WindowsReadingList"

    # Redstone 5 apps
    "Microsoft.MixedReality.Portal"
    "Microsoft.ScreenSketch"
    "Microsoft.XboxGamingOverlay"
    "Microsoft.YourPhone"

    # non-Microsoft
    "9E2F88E3.Twitter"
    "PandoraMediaInc.29680B314EFC2"
    "Flipboard.Flipboard"
    "ShazamEntertainmentLtd.Shazam"
    "king.com.CandyCrushSaga"
    "king.com.CandyCrushSodaSaga"
    "king.com.BubbleWitch3Saga"
    "king.com.*"
    "ClearChannelRadioDigital.iHeartRadio"
    "4DF9E0F8.Netflix"
    "6Wunderkinder.Wunderlist"
    "Drawboard.DrawboardPDF"
    "2FE3CB00.PicsArt-PhotoStudio"
    "D52A8D61.FarmVille2CountryEscape"
    "TuneIn.TuneInRadio"
    "GAMELOFTSA.Asphalt8Airborne"
    #"TheNewYorkTimes.NYTCrossword"
    "DB6EA5DB.CyberLinkMediaSuiteEssentials"
    "Facebook.Facebook"
    "flaregamesGmbH.RoyalRevolt2"
    "Playtika.CaesarsSlotsFreeCasino"
    "A278AB0D.MarchofEmpires"
    "KeeperSecurityInc.Keeper"
    "ThumbmunkeysLtd.PhototasticCollage"
    "XINGAG.XING"
    "89006A2E.AutodeskSketchBook"
    "D5EA27B7.Duolingo-LearnLanguagesforFree"
    "46928bounde.EclipseManager"
    "ActiproSoftwareLLC.562882FEEB491" # next one is for the Code Writer from Actipro Software LLC
    "DolbyLaboratories.DolbyAccess"
    "SpotifyAB.SpotifyMusic"
    "A278AB0D.DisneyMagicKingdoms"
    "WinZipComputing.WinZipUniversal"
    "CAF9E577.Plex"
    "7EE7776C.LinkedInforWindows"
    "613EBCEA.PolarrPhotoEditorAcademicEdition"
    "Fitbit.FitbitCoach"
    "DolbyLaboratories.DolbyAccess"
    "Microsoft.BingNews"
    "NORDCURRENT.COOKINGFEVER"

    # apps which cannot be removed using Remove-AppxPackage
    #"Microsoft.BioEnrollment"
    #"Microsoft.MicrosoftEdge"
    #"Microsoft.Windows.Cortana"
    #"Microsoft.WindowsFeedback"
    #"Microsoft.XboxGameCallableUI"
    #"Microsoft.XboxIdentityProvider"
    #"Windows.ContactSupport"
  )

  foreach ($app in $apps) {
    Write-Output "Trying to remove $app"

    Get-AppxPackage -Name $app -AllUsers | Remove-AppxPackage -AllUsers

    Get-AppXProvisionedPackage -Online |
      Where-Object DisplayName -EQ $app |
      Remove-AppxProvisionedPackage -Online
  }


  # Prevents Apps from re-installing
  force-mkdir "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
  Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "FeatureManagementEnabled" 0
  Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "OemPreInstalledAppsEnabled" 0
  Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "PreInstalledAppsEnabled" 0
  Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "SilentInstalledAppsEnabled" 0
  Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "ContentDeliveryAllowed" 0
  Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "PreInstalledAppsEverEnabled" 0
  Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "SubscribedContentEnabled" 0
  Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "SubscribedContent-338388Enabled" 0
  Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "SubscribedContent-338389Enabled" 0
  Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "SubscribedContent-314559Enabled" 0
  Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "SubscribedContent-338387Enabled" 0
  Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "SubscribedContent-338393Enabled" 0
  Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "SystemPaneSuggestionsEnabled" 0

  force-mkdir "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore"
  Set-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore" "AutoDownload" 2

  # Prevents "Suggested Applications" returning
  force-mkdir "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"
  Set-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" "DisableWindowsConsumerFeatures" 1
}