$toolsJson = Get-Content 'tools.json' -Raw | ConvertFrom-Json

$toolsJson.tools | ForEach-Object {
    $toolDir = Split-Path $_.path -Parent
    $zipName = Split-Path $_.path -Leaf

    if (-not (Test-Path $toolDir)) {
        Write-Host "目录不存在: $toolDir" -ForegroundColor Red
        return
    }

    $zipPath = Join-Path $toolDir $zipName
    if (Test-Path $zipPath) { Remove-Item $zipPath -Force }

    Compress-Archive -Path "$toolDir\*" -DestinationPath $zipPath
    Write-Host "打包完成: $($_.path)" -ForegroundColor Green
}

Write-Host "所有工具打包完成！" -ForegroundColor Cyan
