param (
    [Parameter(Mandatory)]
    [string]$NewVersion,

    [Parameter(Mandatory)]
    [string]$ChangelogEntry,

    [switch]$PushTag
)

$modulePath = "Start-AdConDeltaSync"
$psd1File = Join-Path $modulePath "Start-AdConDeltaSync.psd1"
$changelogFile = Join-Path $modulePath "CHANGELOG.md"

# Update version in .psd1
(Get-Content $psd1File) -replace "ModuleVersion\\s*=\\s*'[^']+'", "ModuleVersion = '$NewVersion'" | Set-Content $psd1File
Write-Host "✅ Updated version in manifest to $NewVersion"

# Update CHANGELOG.md
$today = Get-Date -Format "yyyy-MM-dd"
$changelogHeader = "## [$NewVersion] - $today`n"
$changelogBody = "### Changed`n- $ChangelogEntry`n`n"
$existingContent = Get-Content $changelogFile -Raw
Set-Content $changelogFile -Value ($changelogHeader + $changelogBody + $existingContent)
Write-Host "📝 Added changelog entry"

# Commit and tag
git add $psd1File $changelogFile
git commit -m "Bump version to $NewVersion"
git tag "v$NewVersion"
Write-Host "🏷️  Created Git tag v$NewVersion"

# Optional push
if ($PushTag) {
    git push origin "v$NewVersion"
    Write-Host "🚀 Pushed tag to origin"
}
