<#
.SYNOPSIS
    Installs the Start-AdConDeltaSync PowerShell module to the user's module path.

.DESCRIPTION
    Copies the Start-AdConDeltaSync module files to the appropriate PowerShell Modules folder
    and optionally imports the module.

.PARAMETER ImportAfterInstall
    If specified, imports the module after installation.

.EXAMPLE
    .\Install-DeltaSyncModule.ps1 -ImportAfterInstall
#>

param (
    [switch]$ImportAfterInstall
)

$moduleName = 'Start-AdConDeltaSync'
$sourcePath = "$PSScriptRoot\$moduleName"
$targetPath = Join-Path -Path $env:USERPROFILE -ChildPath "Documents\PowerShell\Modules\$moduleName"

# Create target directory if it doesn't exist
if (-not (Test-Path $targetPath)) {
    New-Item -Path $targetPath -ItemType Directory -Force | Out-Null
}

# Copy module files
Copy-Item -Path "$sourcePath\*" -Destination $targetPath -Recurse -Force

Write-Verbose $("Module '{0}' installed to: {1}" -f $moduleName,$targetPath)

if ($ImportAfterInstall) {
    Import-Module $moduleName -Force
    Write-Verbose $("Module '{0}' imported." -f $moduleName)
}
