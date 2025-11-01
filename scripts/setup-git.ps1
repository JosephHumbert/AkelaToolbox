[CmdletBinding()]
param(
    [Parameter()]
    [string]$RepoPath = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')),

    [Parameter()]
    [string]$UserName = 'Jojo',

    [Parameter()]
    [string]$UserEmail = 'mixjojo2006@protonmail.com',

    [Parameter()]
    [string]$RemoteName = 'origin',

    [Parameter()]
    [string]$RemoteUrl = 'https://github.com/JosephHumbert/AkelaToolbox.git'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    throw "Git n'est pas installé ou introuvable dans le PATH. Veuillez l'installer avant de relancer ce script."
}

if (-not (Test-Path -LiteralPath $RepoPath)) {
    throw "Le chemin du dépôt `$RepoPath` n'existe pas."
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

Invoke-Git -Arguments @('config', 'user.name', $UserName)
Invoke-Git -Arguments @('config', 'user.email', $UserEmail)

$currentUrl = $null
try {
    $currentUrl = Invoke-Git -Arguments @('remote', 'get-url', $RemoteName)
} catch {
    $currentUrl = $null
}

$remoteAction = 'déjà configuré'
if ([string]::IsNullOrWhiteSpace($currentUrl)) {
    Invoke-Git -Arguments @('remote', 'add', $RemoteName, $RemoteUrl)
    $remoteAction = 'ajouté'
} elseif ($currentUrl.Trim() -ne $RemoteUrl) {
    Invoke-Git -Arguments @('remote', 'set-url', $RemoteName, $RemoteUrl)
    $remoteAction = 'mis à jour'
}

$branchStatus = Invoke-Git -Arguments @('status', '-sb')

Write-Host "Configuration Git appliquée pour $RepoPath"
Write-Host "- Nom d'utilisateur : $UserName"
Write-Host "- Adresse email : $UserEmail"
Write-Host "- Remote '$RemoteName' ($remoteAction) : $RemoteUrl"
Write-Host ""
Write-Host "État du dépôt :"
Write-Host ($branchStatus -join [Environment]::NewLine)
