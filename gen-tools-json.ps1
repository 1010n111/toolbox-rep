$tools = @()

Get-ChildItem -Directory | Where-Object {
    $_.Name -notlike '.*' -and $_.Name -ne 'node_modules'
} | ForEach-Object {
    $manifestPath = Join-Path $_.FullName 'manifest.json'
    if (Test-Path $manifestPath) {
        $manifest = Get-Content $manifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
        $zipPath = (Join-Path $_.Name ($manifest.id + '.zip')) -replace '\\', '/'
        $tools += [PSCustomObject]@{
            id = $manifest.id
            name = $manifest.name
            version = $manifest.version
            description = $manifest.description
            author = $manifest.author
            path = $zipPath
        }
        Write-Host ('Found tool: ' + $manifest.name + ' -> ' + $zipPath)
    }
}

[PSCustomObject]@{ tools = $tools } | ConvertTo-Json | Set-Content 'tools.json' -Encoding UTF8
Write-Host ''
Write-Host ('Done: tools.json, ' + $tools.Count + ' tools total') -ForegroundColor Cyan
