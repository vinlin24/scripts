<#
.Synopsis
    Formats delimiters of file names.
.DESCRIPTION
    To be used from the context menu. To add this script to the context menu, run this script with the -Register switch. When run normally afterwards, this script standardizes the delimitation of words in the names of the files in the current directory.
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
    $appPath = Join-Path $HKCU_PATH "FormatSpaces"
    if (Test-Path $appPath) {
        Write-Host "format-spaces is already registered in the registry. Would you like to overwrite it? (y/N) " -NoNewline -ForegroundColor Yellow
        $confirmation = Read-Host
        if ($confirmation -ne "y") {
            exit 0
        }
        Remove-Item $appPath -Recurse
    }

    # Create the container for the app
    Write-Host "Adding format-spaces to the registry..." -ForegroundColor Yellow
    New-Item -Path $appPath
    New-ItemProperty -Path $appPath -Name "(Default)" -Value "Format file names"

    # Create the command subkey pointed to this script
    $commandPath = Join-Path $appPath "command"
    New-Item -Path $commandPath
    $__file__ = $MyInvocation.MyCommand.Path
    $command = "powershell.exe -WindowStyle Hidden -File $__file__"
    New-ItemProperty -Path $commandPath -Name "(Default)" -Value $command

    Write-Host "Key points to the current location of this script: $__file__. If you move this script, be sure to run it with the -Register flag again!" -ForegroundColor Yellow
    Write-Host "Added format-spaces to the registry." -ForegroundColor Green
    exit 0
}

<# Otherwise, run the main process #>

function Format-FileNames {
    # Delimiter used to separate words in final name
    $WORD_DELIMITER = "-"

    # Regex delimiters to detect and replace
    $TARGET_DELIMITERS = @("\s+", "_+")

    $files = Get-ChildItem -Path .

    $count = 0
    foreach ($file in $files) {
        $oldName = $newName = $file.Name
        foreach ($delimiter in $TARGET_DELIMITERS) {
            $newName = $newName -replace $delimiter, $WORD_DELIMITER
        }
        if ($newName -ne $oldName) {
            Rename-Item $file $newName
            Write-Host "Renamed: $oldname -> $newName."
            $count++
        }
    }
    Write-Host "DONE: Renamed $count item(s)."
}

Format-FileNames
exit 0
