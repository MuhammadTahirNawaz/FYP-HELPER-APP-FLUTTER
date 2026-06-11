# Run FYP Helper with Firebase credentials from .env
# Usage:
#   .\run_app.ps1                  # Windows desktop (default)
#   .\run_app.ps1 -android         # Android device/emulator
#   .\run_app.ps1 -chrome          # Chrome (web)
#   .\run_app.ps1 -edge            # Edge (web)
#   .\run_app.ps1 -build -android  # Build APK
#   .\run_app.ps1 -build -windows  # Build Windows release
#   .\run_app.ps1 -build -web      # Build web release

param(
    [string]$device = "windows",
    [switch]$android,
    [switch]$windows,
    [switch]$chrome,
    [switch]$edge,
    [switch]$web,
    [switch]$build
)

$envFile = Join-Path $PSScriptRoot ".env"
if (-not (Test-Path $envFile)) {
    Write-Error ".env file not found at $envFile"
    Write-Error "Copy .env.example to .env and fill in your Firebase credentials"
    exit 1
}

$envVars = @{}
Get-Content $envFile | ForEach-Object {
    if ($_ -match "^([^#=][^=]+)=(.*)$") {
        $envVars[$Matches[1].Trim()] = $Matches[2].Trim()
    }
}

function Get-EnvValue([string]$primaryKey, [string]$fallbackKey) {
    $value = $envVars[$primaryKey]
    if ([string]::IsNullOrWhiteSpace($value) -and $fallbackKey) {
        $value = $envVars[$fallbackKey]
    }
    return $value
}

$androidKey = Get-EnvValue "FIREBASE_ANDROID_API_KEY" $null
$windowsKey = Get-EnvValue "FIREBASE_WINDOWS_API_KEY" "FIREBASE_WEB_API_KEY"
$windowsAppId = Get-EnvValue "FIREBASE_WINDOWS_APP_ID" "FIREBASE_WEB_APP_ID"
$webKey = Get-EnvValue "FIREBASE_WEB_API_KEY" "FIREBASE_WINDOWS_API_KEY"
$webAppId = Get-EnvValue "FIREBASE_WEB_APP_ID" "FIREBASE_WINDOWS_APP_ID"

if ([string]::IsNullOrWhiteSpace($androidKey)) {
    Write-Error "Missing FIREBASE_ANDROID_API_KEY in .env file"
    exit 1
}
if ([string]::IsNullOrWhiteSpace($windowsKey)) {
    Write-Error "Missing FIREBASE_WINDOWS_API_KEY (or FIREBASE_WEB_API_KEY fallback) in .env file"
    exit 1
}
if ([string]::IsNullOrWhiteSpace($windowsAppId)) {
    Write-Error "Missing FIREBASE_WINDOWS_APP_ID (or FIREBASE_WEB_APP_ID fallback) in .env file"
    exit 1
}
if ([string]::IsNullOrWhiteSpace($webKey)) {
    Write-Error "Missing FIREBASE_WEB_API_KEY (or FIREBASE_WINDOWS_API_KEY fallback) in .env file"
    exit 1
}
if ([string]::IsNullOrWhiteSpace($webAppId)) {
    Write-Error "Missing FIREBASE_WEB_APP_ID (or FIREBASE_WINDOWS_APP_ID fallback) in .env file"
    exit 1
}

Write-Host "Loaded Firebase credentials from .env" -ForegroundColor Green

$dartDefine = @(
    "--dart-define=FIREBASE_ANDROID_API_KEY=$androidKey",
    "--dart-define=FIREBASE_WINDOWS_API_KEY=$windowsKey",
    "--dart-define=FIREBASE_WINDOWS_APP_ID=$windowsAppId",
    "--dart-define=FIREBASE_WEB_API_KEY=$webKey",
    "--dart-define=FIREBASE_WEB_APP_ID=$webAppId"
)

$target = if ($android) {
    "android"
} elseif ($chrome -or $web) {
    "chrome"
} elseif ($edge) {
    "edge"
} elseif ($windows) {
    "windows"
} else {
    $device
}

if ($build) {
    if ($android -or $target -eq "android") {
        $flutterCmd = "flutter build apk $($dartDefine -join ' ')"
    } elseif ($chrome -or $edge -or $web -or $target -eq "chrome" -or $target -eq "edge") {
        $flutterCmd = "flutter build web $($dartDefine -join ' ')"
    } else {
        $flutterCmd = "flutter build windows $($dartDefine -join ' ')"
    }
} else {
    $flutterCmd = "flutter run -d $target $($dartDefine -join ' ')"
}

Write-Host "Running: $flutterCmd" -ForegroundColor Cyan
Invoke-Expression $flutterCmd
