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

$__file__ = $MyInvocation.MyCommand.Path

<# Add script to registry if run with -Register switch #>

function _register_at_path {
    param (
        [Parameter(Mandatory = $true)]
        [string] $AppPath
    )
    # Create the container for the app
    New-Item -Path $AppPath
    New-ItemProperty -LiteralPath $AppPath -Name "(Default)" -Value "Add desktop shortcut"

    # Create the command subkey pointed to this script
    $commandPath = Join-Path $AppPath "command"
    New-Item -Path $commandPath
    # "%1" necessary to capture selected file
    $command = "powershell.exe -WindowStyle Hidden -File $__file__ `"%1`""
    New-ItemProperty -LiteralPath $commandPath -Name "(Default)" -Value $command
}

if ($Register) {
    # WARNING: Use -LiteralPath for any operations with paths containing *
    $HKCU_FILES_PATH = "HKCU:\Software\Classes\*\shell\"
    $HKCU_DIR_PATH = "HKCU:\Software\Classes\Directory\shell\"
    
    # Ask to overwrite the existing keys if any already exist
    $appFilesPath = Join-Path $HKCU_FILES_PATH "DesktopShortcut"
    $appDirPath = Join-Path $HKCU_DIR_PATH "DesktopShortcut"
    if ((Test-Path -LiteralPath $appFilesPath) -or (Test-Path -Path $appDirPath)) {
        Write-Host "desktop-shortcut is already registered in the registry. Would you like to overwrite it? (y/N) " -NoNewline -ForegroundColor Yellow
        $confirmation = Read-Host
        if ($confirmation -ne "y") {
            exit 0
        }
        try { Remove-Item -LiteralPath $appFilesPath -Recurse } catch {}
        try { Remove-Item -Path $appDirPath -Recurse } catch {}
    }

    # For context menu on FILES
    Write-Host "Adding desktop-shortcut to the registry (FILES)..." -ForegroundColor Yellow
    _register_at_path $appFilesPath

    # For context menu on DIRECTORIES
    Write-Host "Adding desktop-shortcut to the registry (DIRECTORIES)..." -ForegroundColor Yellow
    _register_at_path $appDirPath

    Write-Host "Keys points to the current location of this script: $__file__. If you move this script, be sure to run it with the -Register flag again!" -ForegroundColor Yellow
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
