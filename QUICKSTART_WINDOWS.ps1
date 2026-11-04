$ErrorActionPreference = 'Stop'
Write-Host 'ICE DevSecOps demo - local repository preparation' -ForegroundColor Cyan
if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
    throw 'Node.js/npm not found. Install a current Node.js LTS release, reopen PowerShell, and retry.'
}
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    throw 'Git not found. Install Git for Windows, reopen PowerShell, and retry.'
}
npm install
Write-Host 'Local dependency install complete. Commit package-lock.json before uploading/pushing.' -ForegroundColor Green
Write-Host 'Do not add SNYK_TOKEN to this folder or commit any secrets.' -ForegroundColor Yellow
