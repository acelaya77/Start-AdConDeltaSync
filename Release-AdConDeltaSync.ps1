[CmdletBinding()]

param (
    [Parameter(Mandatory)]
    [string]$NewVersion,

    [Parameter(Mandatory)]
    [string]$ChangelogEntry,

    [switch]$PushTag
)

$modulePath = "."
$psd1File = Join-Path $modulePath "Start-AdConDeltaSync.psd1"
$changelogFile = Join-Path $modulePath "CHANGELOG.md"

# Update version in .psd1
(Get-Content $psd1File) -replace "ModuleVersion\s*=\s*'[^']+'", $("ModuleVersion = '{0}'" -f $NewVersion) | Set-Content $psd1File
$string = 'Updated version in manifest to {0}' -f $NewVersion
Write-Verbose $string

# Update CHANGELOG.md
$today = Get-Date -Format "yyyy-MM-dd"
$changelogHeader = "## [{0}] - {1}`n" -f $NewVersion,$today
$changelogBody = "### Changed`n- {0}`n`n" -f $ChangelogEntry
$existingContent = Get-Content $changelogFile -Raw
Set-Content $changelogFile -Value ($changelogHeader + $changelogBody + $existingContent)
$string = 'Added changelog entry'
Write-Verbose $string

# Commit and tag
$command = "git add {0} {1}" -f $psd1File,$changelogFile
$scriptBlock = [ScriptBlock]::Create($command)
Invoke-Command $scriptBlock

$command = "git commit -m ""Bump version to {0}""" -f $NewVersion
$scriptBlock = [ScriptBlock]::Create($command)
Invoke-Command $scriptBlock

$command = "git tag ""v{0}""" -f $NewVersion
$scriptBlock = [ScriptBlock]::Create($command)
Invoke-Command $scriptBlock
$string = 'Created Git tag v{0}' -f $NewVersion
Write-Verbose $string

# Optional push
if ($PushTag) {
    $command = "git push origin ""v{0}""" -f $NewVersion
    $scriptBlock = [ScriptBlock]::Create($command)
    Invoke-Command $scriptBlock
    $string = 'Pushed tag to origin'
    Write-Verbose $string
}
