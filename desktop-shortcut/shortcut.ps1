<#
.Synopsis
    Creates a desktop shortcut for a selected file.
.DESCRIPTION
    To be used from the context menu. To add this script to the context menu, run this script with the -Register switch. When run normally afterwards, this script creates a shortcut on the user's desktop with the same file name. Notably, it excludes the annoying ' - Shortcut' suffix.
.PARAMETER File
    The file to create a desktop shortcut for. Passed automatically when used from the context menu.
.PARAMETER Register
    If this switch is included, the main program is not run. Instead, the script registers itself in the registry to make it available from the context menu
.NOTES
    Author: Vincent Lin
    Date:   18 September 2022
#>

param (
    # To be passed from "%1" by the Registry
    [Parameter()]
    [string] $File,
    [Parameter()]
    [switch] $Register
)

<# Add script to registry if run with -Register switch #>

if ($Register) {
    # WARNING: Use -LiteralPath for any operations with paths containing *
    $HKCU_PATH = "HKCU:\Software\Classes\*\shell\"
    
    # Ask to overwrite the existing key if already exists
    $appPath = Join-Path $HKCU_PATH "DesktopShortcut"
    if (Test-Path -LiteralPath $appPath) {
        Write-Host "desktop-shortcut is already registered in the registry. Would you like to overwrite it? (y/N) " -NoNewline -ForegroundColor Yellow
        $confirmation = Read-Host
        if ($confirmation -ne "y") {
            exit 0
        }
        Remove-Item -LiteralPath $appPath -Recurse
    }

    # Create the container for the app
    Write-Host "Adding desktop-shortcut to the registry..." -ForegroundColor Yellow
    New-Item -Path $appPath
    New-ItemProperty -LiteralPath $appPath -Name "(Default)" -Value "Add desktop shortcut"

    # Create the command subkey pointed to this script
    $commandPath = Join-Path $appPath "command"
    New-Item -Path $commandPath
    $__file__ = $MyInvocation.MyCommand.Path
    # "%1" necessary to capture selected file
    $command = "powershell.exe -WindowStyle Hidden -File $__file__ `"%1`""
    New-ItemProperty -LiteralPath $commandPath -Name "(Default)" -Value $command

    Write-Host "Key points to the current location of this script: $__file__. If you move this script, be sure to run it with the -Register flag again!" -ForegroundColor Yellow
    Write-Host "Added desktop-shortcut to the registry." -ForegroundColor Green
    exit 0
}

<# Otherwise run normally #>

if ($File -eq "") {
    Write-Host "No file selected, aborted." -ForegroundColor Red
    exit 1
}

function Add-DesktopShortcut {
    param (
        [Parameter(Mandatory = $true)]
        [string] $TargetFile
    )

    # Get System.IO.FileSystemInfo object from provided path
    try {
        $fileInfo = Get-Item -Path $TargetFile
    }
    catch {
        Write-Host "Could not resolve the path $targetFile."
        exit 1
    }
    
    # Prepare the shortcut path
    $shortcutPath = "$env:USERPROFILE\Desktop\$($fileInfo.Name).lnk"
    Write-Host "Preparing a shortcut file at $shortcutPath that targets $fileInfo." -ForegroundColor Yellow
    
    # Create the file: https://www.pdq.com/blog/pdq-deploy-and-powershell/
    $WScriptShell = New-Object -ComObject WScript.Shell
    $shortcut = $WScriptShell.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = $fileInfo
    $shortcut.Save()
    Write-Host "Created shortcut file." -ForegroundColor Green
}

Add-DesktopShortcut $File
exit 0
