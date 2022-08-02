# downloads.ps1

# can add script-level arguments with param() later

# string to prefix output lines for this script
$PREFIX = "(downloads.ps1)"

function Confirm-PasteAction {
    $cwd = Get-Location
    Write-Host "$PREFIX Your current working directory is $cwd." -ForegroundColor Yellow
    Write-Host "$PREFIX Do you want to move these files here? Press [ENTER] to continue, or any key to cancel." -ForegroundColor Yellow
    $key_input = [System.Console]::ReadKey($true).Key
    if ($key_input -ne [System.ConsoleKey]::Enter) {
        Write-Host "$PREFIX Action cancelled." -ForegroundColor Red
        return
    }
    Move-NewItems
}

function Move-NewItems {
    $cwd = Get-Location
    foreach ($item in $new_items) {
        $new_path = "$($cwd.ToString())\$($item.Name)"
        $item.MoveTo($new_path)
    }
    Write-Host "$PREFIX Moved $($new_items.Length) items to $cwd." -ForegroundColor Green
}

# ENTRY POINT:

function Start-MyScript {
    # https://stackoverflow.com/questions/57947150/where-is-the-downloads-folder-located
    $downloads = (New-Object -ComObject Shell.Application).NameSpace('shell:Downloads').Self.Path

    $reference_time = (Get-Date).AddHours(-1)
    $new_items = Get-ChildItem -Path $downloads | Where-Object { $_.CreationTime -gt $reference_time } 

    # learning note: apparently literals should be on the LHS
    if ($null -eq $new_items) {
        Write-Host "$PREFIX No files from the last hour found in the Downloads folder!" -ForegroundColor Red
    }
    else {
        Write-Host "$PREFIX Found the following files from the last hour in the Downloads folder:" -ForegroundColor Yellow
        # Format-Table returns an Object[] that needs to be decoded before printing
        $new_items | Format-Table -Property Name, CreationTime | Out-String | Write-Host
        Confirm-PasteAction
    }
}

# I like compartmentalizing my code, deal with it
Start-MyScript