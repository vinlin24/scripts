<# Automate editing the registry #>

param (
    [Parameter(Mandatory = $true)]
    [string[]] $Path
)

Write-Host "Adding downloads-paster to the registry..." -ForegroundColor Yellow

$HKCU_PATH = "HKCU:\Software\Classes\Directory\Background\shell\"

# Create the container for the application
$appPath = Join-Path $HKCU_PATH "Downloads"
New-Item -Path $appPath
New-ItemProperty -Path $appPath -Name "(Default)" -Value "Paste from Downloads"

# Create the command subkey
$commandPath = Join-Path $appPath "command"
New-Item -Path $commandPath
try {
    $scriptPath = Resolve-Path $Path
}
catch {
    Write-Host "The inputted path $Path could not be resolved, aborted." -ForegroundColor Red
    exit 1
}
$command = "powershell.exe -File $scriptPath"
New-ItemProperty -Path $commandPath -Name "(Default)" -Value $command

Write-Host "Added downloads-paster to the registry." -ForegroundColor Green
exit 0
