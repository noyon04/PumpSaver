# Fetches Fuel Finder data from this (UK) PC and publishes stations.json to the gh-pages branch,
# which GitHub Pages serves at https://noyon04.github.io/PumpSaver/stations.json.
#
# Why a PC: the Fuel Finder API only accepts UK traffic (CloudFront returns 403 to GitHub's US runners).
# Credentials come from Windows user environment variables FUEL_FINDER_CLIENT_ID / FUEL_FINDER_CLIENT_SECRET.
# Scheduled by Task Scheduler (task "PumpSaver fetch"). Log: F:\Android\tmp\pumpsaver_publish.log
# ponytail: runs only while this PC is on and logged in; move to a UK cloud function when that matters.

# 'Continue' because git and dart print progress to stderr, which 'Stop' treats as fatal in PowerShell 5.1.
# Failures are detected from exit codes instead.
$ErrorActionPreference = 'Continue'
$repo = Split-Path -Parent $PSScriptRoot
$log = 'F:\Android\tmp\pumpsaver_publish.log'
$publishDir = 'F:\Android\tmp\pumpsaver_gh_pages'

function Log($message) { "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')  $message" | Add-Content -Path $log -Encoding utf8 }

try {
    # Task Scheduler and freshly started shells may not have these yet, so read them from the user scope.
    foreach ($name in 'FUEL_FINDER_CLIENT_ID', 'FUEL_FINDER_CLIENT_SECRET', 'PUB_CACHE') {
        $value = [Environment]::GetEnvironmentVariable($name, 'User')
        if (-not $value) { throw "User environment variable $name is not set." }
        Set-Item -Path "env:$name" -Value $value
    }

    Set-Location $repo
    $output = & F:\flutter\bin\dart.bat run tool/fetch_fuel_data.dart 2>&1 | Out-String
    if ($LASTEXITCODE -ne 0) { throw "Fetch failed: $(($output -split "`n" | Select-String '::error|Error' | Select-Object -First 1))" }

    # Publish as a single orphan commit, force-pushed, so the repo history doesn't grow every 30 minutes.
    $remote = (git -C $repo remote get-url origin).Trim()
    if (Test-Path $publishDir) { Remove-Item $publishDir -Recurse -Force }
    New-Item -ItemType Directory -Path $publishDir | Out-Null
    Copy-Item "$repo\public\stations.json" $publishDir
    New-Item -ItemType File -Path "$publishDir\.nojekyll" | Out-Null

    git -C $publishDir init -q -b gh-pages
    git -C $publishDir add -A
    git -C $publishDir -c user.name='PumpSaver publisher' -c user.email='noreply@github.com' commit -q -m "Fuel prices $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
    if ($LASTEXITCODE -ne 0) { throw 'git commit failed.' }
    git -C $publishDir push -q --force $remote gh-pages 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) { throw 'git push to gh-pages failed.' }

    Log "OK  $(($output -split "`n" | Select-String 'Wrote') -replace '\s+$','')"
} catch {
    Log "FAILED  $($_.Exception.Message)"
    exit 1
}
