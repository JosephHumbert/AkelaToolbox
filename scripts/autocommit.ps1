[CmdletBinding()]
param(
    [Parameter(Mandatory, Position = 0)]
    [string]$Message,

    [Parameter()]
    [string]$RepoPath = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')),

    [Parameter()]
    [switch]$SkipPush
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($Message)) {
    throw "Le message de commit ne peut pas être vide."
}

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    throw "Git n'est pas installé ou introuvable dans le PATH. Veuillez l'installer avant de relancer ce script."
}

if (-not (Test-Path -LiteralPath $RepoPath)) {
    throw "Le chemin `$RepoPath` est introuvable."
}

$gitFolder = Join-Path -Path $RepoPath -ChildPath '.git'
if (-not (Test-Path -LiteralPath $gitFolder)) {
    throw "Le dossier `$RepoPath` ne semble pas être un dépôt Git."
}

function Invoke-Git {
    param(
        [Parameter(Mandatory)]
        [string[]]$Arguments
    )

    & git -C $RepoPath @Arguments
}

Invoke-Git -Arguments @('add', '--all')

$stagedChanges = Invoke-Git -Arguments @('diff', '--cached', '--name-only')
if ([string]::IsNullOrWhiteSpace(($stagedChanges -join '').Trim())) {
    Write-Host "Aucun changement à committer."
    return
}

Invoke-Git -Arguments @('commit', '-m', $Message)

if (-not $SkipPush) {
    $currentBranch = (Invoke-Git -Arguments @('rev-parse', '--abbrev-ref', 'HEAD')).Trim()
    if ([string]::IsNullOrWhiteSpace($currentBranch)) {
        throw "Impossible de déterminer la branche courante."
    }

    Invoke-Git -Arguments @('push', 'origin', $currentBranch)
}

Write-Host "Commit et push effectués avec succès."
