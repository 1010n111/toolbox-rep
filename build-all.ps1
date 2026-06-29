$tools = @()

Get-ChildItem -Directory | Where-Object {
  $_.Name -notlike '.*' -and $_.Name -ne 'node_modules' -and $_.Name -ne 'docs'
} | ForEach-Object {
  $manifestPath = Join-Path $_.FullName 'manifest.json'
  if (Test-Path $manifestPath) {
    $manifest = Get-Content $manifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
    $zipName = $manifest.id + '.zip'
    $zipPath = Join-Path $_.FullName $zipName

    # Delete existing zip
    if (Test-Path $zipPath) { Remove-Item $zipPath -Force }

    # Build zip
    Compress-Archive -Path (Join-Path $_.FullName '*') -DestinationPath $zipPath
    Write-Host ('Built: ' + $manifest.name + ' -> ' + (Join-Path $_.Name $zipName)) -ForegroundColor Green

    # Add to tools list
    $tools += [PSCustomObject]@{
      id = $manifest.id
      name = $manifest.name
      version = $manifest.version
      description = $manifest.description
      author = $manifest.author
      path = (Join-Path $_.Name $zipName) -replace '\\', '/'
    }
  }
}

# Generate tools.json
[PSCustomObject]@{ tools = $tools } | ConvertTo-Json | Set-Content 'tools.json' -Encoding UTF8
Write-Host ''
Write-Host ('Done! ' + $tools.Count + ' tools built, tools.json updated') -ForegroundColor Cyan
