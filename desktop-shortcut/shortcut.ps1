# Extract selected file from %1 passed from Registry
$selectedFile = $args[0]

if ($null -eq $selectedFile) {
    Write-Host "No file selected!" -ForegroundColor Red
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

Add-DesktopShortcut $selectedFile
exit 0
