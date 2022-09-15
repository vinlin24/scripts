<#
.Synopsis
    Moves files from Downloads into current directory.
.DESCRIPTION
    To be used from the context menu. To add this script to the context menu, run this script with the -Register switch. When run normally afterwards, this script moves all files with creation time 5 minutes old or newer from the Downloads folder to the current directory.
.PARAMETER Register
    If this switch is included, the main program is not run. Instead, the script registers itself in the registry to make it available from the context menu
.NOTES
    Author: Vincent Lin
    Date:   14 September 2022
#>

param (
    [Parameter()]
    [switch] $Register
)

<# Add script to registry if run with -Register switch #>

if ($Register) {
    $HKCU_PATH = "HKCU:\Software\Classes\Directory\Background\shell\"
    
    # Ask to overwrite the existing key if already exists
    $appPath = Join-Path $HKCU_PATH "Downloads"
    if (Test-Path $appPath) {
        Write-Host "downloads-paster is already registered in the registry. Would you like to overwrite it? (y/N) " -NoNewline -ForegroundColor Yellow
        $confirmation = Read-Host
        if ($confirmation -ne "y") {
            exit 0
        }
        Remove-Item $appPath -Recurse
    }

    # Create the container for the app
    Write-Host "Adding downloads-paster to the registry..." -ForegroundColor Yellow
    New-Item -Path $appPath
    New-ItemProperty -Path $appPath -Name "(Default)" -Value "Paste from Downloads"

    # Create the command subkey pointed to this script
    $commandPath = Join-Path $appPath "command"
    New-Item -Path $commandPath
    $__file__ = $MyInvocation.MyCommand.Path
    $command = "powershell.exe -WindowStyle Hidden -File $__file__"
    New-ItemProperty -Path $commandPath -Name "(Default)" -Value $command

    Write-Host "Key points to the current location of this script: $__file__. If you move this script, be sure to run it with the -Register flag again!" -ForegroundColor Yellow
    Write-Host "Added downloads-paster to the registry." -ForegroundColor Green
    exit 0
}

function Move-RecentItems {
    $TIMESPAN = New-TimeSpan -Minutes 5
    $downloads = (New-Object -ComObject Shell.Application).NameSpace('shell:Downloads').Self.Path
    $referenceTime = (Get-Date).Add(-$TIMESPAN)
    $recentItems = @(Get-ChildItem -Path $downloads | Where-Object { $_.CreationTime -gt $referenceTime })
    if ($recentItems.Length -eq 0) {
        Write-Host "No items found that was created 5 minutes ago or more recently." -ForegroundColor Yellow
        return
    }
    $cwd = Get-Location
    foreach ($item in $recentItems) {
        $newPath = "$($cwd.ToString())\$($item.Name)"
        $item.MoveTo($newPath)
    }
    # Debugging, shouldn't show up when run from context menu
    Write-Host "Moved $($recentItems.Length) item(s) to $cwd." -ForegroundColor Green
}

Move-RecentItems
exit 0
