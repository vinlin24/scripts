<# Automate editing the registry #>

Write-Host "Adding downloads-paster to the registry..." -ForegroundColor Yellow

$HKCU_PATH = "HKCU:\Software\Classes\Directory\Background\shell\"

# Create the container for the application
$appPath = Join-Path $HKCU_PATH "Downloads"
New-Item -Path $appPath
New-ItemProperty -Path $appPath -Name "(Default)" -Value "Paste from Downloads"

# Create the command subkey
$commandPath = Join-Path $appPath "command"
New-Item -Path $commandPath
$command = "powershell.exe -File C:\Users\soula\repos\scripts\test\test.ps1"
New-ItemProperty -Path $commandPath -Name "(Default)" -Value $command

Write-Host "Added downloads-paster to the registry." -ForegroundColor Green
