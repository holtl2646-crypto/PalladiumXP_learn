param(
    [string]$GatewayHost = "<jump-host>",
    [string]$PxpHost = "<pxp-host>",
    [string]$GatewayUser,
    [string]$PxpUser
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($GatewayUser)) {
    $GatewayUser = Read-Host "Username for jump server $GatewayHost"
}

if ([string]::IsNullOrWhiteSpace($PxpUser)) {
    $PxpUser = Read-Host "Username for PXP $PxpHost"
}

$sshDir = Join-Path $HOME ".ssh"
$configPath = Join-Path $sshDir "config"

if (-not (Test-Path $sshDir)) {
    New-Item -ItemType Directory -Path $sshDir | Out-Null
}

$beginMarker = "# >>> PalladiumXP PXP jump host"
$endMarker = "# <<< PalladiumXP PXP jump host"

$managedBlock = @"
$beginMarker
Host pxp-gateway
    HostName $GatewayHost
    User $GatewayUser
    ServerAliveInterval 30
    ServerAliveCountMax 3

Host pxp
    HostName $PxpHost
    User $PxpUser
    ProxyJump pxp-gateway
    ServerAliveInterval 30
    ServerAliveCountMax 3
$endMarker
"@

$existing = ""
if (Test-Path $configPath) {
    $existing = Get-Content -Raw -Path $configPath
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    Copy-Item -Path $configPath -Destination "$configPath.bak-$timestamp"
}

$pattern = "(?s)" + [regex]::Escape($beginMarker) + ".*?" + [regex]::Escape($endMarker) + "\s*"
if ($existing -match [regex]::Escape($beginMarker)) {
    $newConfig = [regex]::Replace($existing, $pattern, $managedBlock + [Environment]::NewLine)
} elseif ([string]::IsNullOrWhiteSpace($existing)) {
    $newConfig = $managedBlock + [Environment]::NewLine
} else {
    $newConfig = $existing.TrimEnd() + [Environment]::NewLine + [Environment]::NewLine + $managedBlock + [Environment]::NewLine
}

Set-Content -Path $configPath -Value $newConfig -Encoding ascii

Write-Host "SSH config updated: $configPath"
Write-Host ""
Write-Host "Test jump server:"
Write-Host "  ssh pxp-gateway"
Write-Host ""
Write-Host "Connect to PXP through jump server:"
Write-Host "  ssh pxp"
Write-Host ""
Write-Host "Copy a file from PXP to current directory:"
Write-Host "  scp pxp:/path/to/file ."
