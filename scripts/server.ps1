[CmdletBinding()]
param(
    [Parameter()]
    [string]$RootPath = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')),

    [Parameter()]
    [string[]]$ExtraArgs = @()
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if (-not (Get-Command npx -ErrorAction SilentlyContinue)) {
    throw "Node.js (npx) n'est pas installé ou introuvable dans le PATH. Installez Node.js puis relancez ce script."
}

if (-not (Test-Path -LiteralPath $RootPath)) {
    throw "Le chemin `$RootPath` est introuvable."
}

$resolvedRoot = Resolve-Path -LiteralPath $RootPath

Push-Location -LiteralPath $resolvedRoot.Path
try {
    $serveArgs = @('--yes', 'serve', '.')

    if ($ExtraArgs.Count -gt 0) {
        $serveArgs += $ExtraArgs
    }

    Write-Host "Exécution de : npx $($serveArgs -join ' ')"
    & npx @serveArgs
} finally {
    Pop-Location
}
