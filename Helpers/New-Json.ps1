function New-Json {

  $Json = [ordered]@{
    developer_apps = @(
      "atom",
      "sourcetree"
    )
    personal_apps  = @(
      "box"
    )
  }

  $Json | ConvertTo-Json | Out-File -FilePath .\config.json -Force

}

New-Json
