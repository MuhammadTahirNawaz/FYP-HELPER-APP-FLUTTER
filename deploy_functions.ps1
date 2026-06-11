# Deploy Firebase Cloud Functions + database rules (fixes missing Node.js PATH)
# Usage:
#   .\deploy_functions.ps1
#   .\deploy_functions.ps1 -databaseOnly
#   .\deploy_functions.ps1 -functionsOnly

param(
    [switch]$databaseOnly,
    [switch]$functionsOnly
)

$nodeDir = "C:\Program Files\nodejs"
$nodeExe = Join-Path $nodeDir "node.exe"

if (-not (Test-Path $nodeExe)) {
    Write-Error "Node.js not found at $nodeExe"
    Write-Error "Install LTS from https://nodejs.org/ then run this script again."
    exit 1
}

# Prepend Node to PATH for this session (firebase CLI needs node.exe)
$env:Path = "$nodeDir;$env:Path"

Write-Host "Node: $(node --version)" -ForegroundColor Green
Write-Host "npm:  $(npm --version)" -ForegroundColor Green

Set-Location $PSScriptRoot

if ($databaseOnly) {
    $target = "database"
} elseif ($functionsOnly) {
    $target = "functions"
} else {
    $target = "functions,database"
}

Write-Host "Deploying: $target" -ForegroundColor Cyan
firebase deploy --only $target

if ($LASTEXITCODE -ne 0) {
    Write-Error "Deploy failed (exit code $LASTEXITCODE)"
    exit $LASTEXITCODE
}

Write-Host "Deploy complete." -ForegroundColor Green
