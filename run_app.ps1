# PowerShell script to run Flutter app with environment variables from .env file
# Usage: .\run_app.ps1 [-device chrome] [-web] [-android] [-build]

param(
    [string]$device = "chrome",
    [switch]$web,
    [switch]$android,
    [switch]$build
)

# Load .env file
$envFile = Join-Path $PSScriptRoot ".env"
if (-not (Test-Path $envFile)) {
    Write-Error ".env file not found at $envFile"
    Write-Error "Copy .env.example to .env and fill in your Firebase credentials"
    exit 1
}

# Parse .env file
$envVars = @{}
Get-Content $envFile | ForEach-Object {
    if ($_ -match "^([^#=][^=]+)=(.*)$") {
        $envVars[$Matches[1].Trim()] = $Matches[2].Trim()
    }
}

# Validate required keys
$requiredKeys = @("FIREBASE_WEB_API_KEY", "FIREBASE_ANDROID_API_KEY")
foreach ($key in $requiredKeys) {
    if (-not $envVars.ContainsKey($key) -or [string]::IsNullOrWhiteSpace($envVars[$key])) {
        Write-Error "Missing $key in .env file"
        exit 1
    }
}

Write-Host "✓ Loaded Firebase credentials from .env" -ForegroundColor Green

# Build dart-define arguments
$dartDefine = @(
    "--dart-define=FIREBASE_WEB_API_KEY=$($envVars['FIREBASE_WEB_API_KEY'])",
    "--dart-define=FIREBASE_ANDROID_API_KEY=$($envVars['FIREBASE_ANDROID_API_KEY'])"
)

# Determine target
$target = if ($web) { "chrome" } elseif ($android) { "android" } else { $device }

# Build command
$flutterCmd = "flutter"
if ($build) {
    $flutterCmd = "$flutterCmd build"
} else {
    $flutterCmd = "$flutterCmd run"
}

# Add target
if (-not $build) {
    $flutterCmd = "$flutterCmd -d $target"
}

# Add dart defines
$flutterCmd = "$flutterCmd $($dartDefine -join ' ')"

Write-Host "Running: $flutterCmd" -ForegroundColor Cyan
Invoke-Expression $flutterCmd
