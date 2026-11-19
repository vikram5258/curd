# Installs the latest `curd` release for Windows.
#
#   irm https://raw.githubusercontent.com/vikram5258/curd/main/install.ps1 | iex
#
# Options (environment variables):
#   CURD_VERSION      release to install, e.g. v0.1.2 (default: latest)
#   CURD_INSTALL_DIR  where to put the binary (default: %LOCALAPPDATA%\Programs\curd)
$ErrorActionPreference = 'Stop'

$repo = 'vikram5258/curd'
$target = 'x86_64-pc-windows-msvc'
$installDir = if ($env:CURD_INSTALL_DIR) { $env:CURD_INSTALL_DIR } else { Join-Path $env:LOCALAPPDATA 'Programs\curd' }

$version = $env:CURD_VERSION
if (-not $version) {
    $version = (Invoke-RestMethod "https://api.github.com/repos/$repo/releases/latest").tag_name
}
if ($version -notlike 'v*') {
    throw "Could not work out the latest version (got '$version')"
}

$name = "curd-$version-$target"
$url = "https://github.com/$repo/releases/download/$version/$name.zip"
$tmp = Join-Path ([System.IO.Path]::GetTempPath()) "curd-install-$PID"
New-Item -ItemType Directory -Force -Path $tmp | Out-Null

try {
    Write-Host "Downloading curd $version for $target..."
    Invoke-WebRequest -Uri $url -OutFile (Join-Path $tmp 'curd.zip') -UseBasicParsing
    Expand-Archive -Path (Join-Path $tmp 'curd.zip') -DestinationPath $tmp -Force

    New-Item -ItemType Directory -Force -Path $installDir | Out-Null
    Copy-Item (Join-Path $tmp "$name\curd.exe") (Join-Path $installDir 'curd.exe') -Force
}
finally {
    Remove-Item -Recurse -Force $tmp -ErrorAction SilentlyContinue
}

Write-Host "Installed curd $version to $installDir\curd.exe"

# Add the install folder to the user's PATH if it is not there yet.
$userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
if (($userPath -split ';') -notcontains $installDir) {
    [Environment]::SetEnvironmentVariable('Path', "$userPath;$installDir", 'User')
    Write-Host "Added $installDir to your PATH. Open a new terminal, then run: curd <file>"
}
else {
    Write-Host 'Run it with: curd <file>'
}
