# Makes a fresh JSON with all common apps added

$Json = [ordered]@{
  developer_apps = @(
    "atom",
    "awscli",
    "azure-cli",
    "chefdk",
    "cmder",
    "conemu",
    "docker-cli",
    "dotnetcore-sdk",
    "git",
    "github-desktop",
    "gitkraken",
    "golang",
    "hyper",
    "kubernetes-cli",
    "mysql.workbench",
    "nodejs",
    "notepadplusplus",
    "postman",
    "powershell-core",
    "putty",
    "python",
    "python2",
    "ruby",
    "sourcetree",
    "sql-server-management-studio",
    "sublimetext3",
    "terraform",
    "vagrant",
    "virtualbox",
    "visualstudio2017enterprise",
    "vmwareworkstation",
    "vscode",
    "yarn"
  )
  it_apps        = @(
    "fiddler",
    "filezilla",
    "malwarebytes",
    "rdcman",
    "rsat",
    "rufus",
    "sysinternals",
    "windirstat",
    "winscp",
    "wireshark"
  )
  personal_apps  = @(
    "7zip",
    "adobereader",
    "box",
    "discord",
    "dropbox",
    "everything",
    "firefox",
    "f.lux",
    "gimp",
    "googlechrome",
    "googledrive",
    "greenshot",
    "sharex",
    "skype",
    "slack",
    "spotify",
    "steam",
    "vlc",
    "winrar",
    "zoom"
  )
}

$Json | ConvertTo-Json | Out-File -FilePath .\config_template.json -Force