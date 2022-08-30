# downloads.ps1
# For use at the command line. Supports command line arguments and
# prompts user for confirmation.

# command line arguments: specify how recent files should be
# args behavior determined by builtin New-Timespan
param (
    [int]$Seconds,
    [int]$Minutes,
    [int]$Hours,
    [int]$Days,
    [switch]$Default  # kind of pointless right now but looks ~readable~
)

# string to prefix output lines for this script
$PREFIX = "(downloads.ps1)"
# default timespan to use if script called with no args
$DEFAULT_TIMESPAN = New-TimeSpan -Minutes 5

function Convert-TimeArgs {
    # assume passing zeroes means caller didn't pass args
    if ($Default -or
        ($Seconds -eq 0 -and
        $Minutes -eq 0 -and
        $Hours -eq 0 -and
        $Days -eq 0)) {
        return $DEFAULT_TIMESPAN
    }

    return New-TimeSpan -Days $Days -Hours $Hours -Minutes $Minutes -Seconds $Seconds
}

function Format-TimeAgo {
    param (
        [System.TimeSpan]$timespan
    )

    [string[]]$strings = @()
    if ($timespan.Days -gt 0) {
        $strings += "$($timespan.Days) days"
    }
    if ($timespan.Hours -gt 0) {
        $strings += "$($timespan.Hours) hours"
    }
    if ($timespan.Minutes -gt 0) {
        $strings += "$($timespan.Minutes) minutes"
    }
    if ($timespan.Seconds -gt 0) {
        $strings += "$($timespan.Seconds) seconds"
    }
    return $strings -Join ", "
}

function Confirm-PasteAction {
    param (
        [int]$num_files
    )

    $cwd = Get-Location
    Write-Host "$PREFIX Your current working directory is $cwd." -ForegroundColor Yellow
    Write-Host "$PREFIX Do you want to move these ($num_files) files here? Press [ENTER] to continue, or any key to cancel." -ForegroundColor Yellow
    
    $key_input = [System.Console]::ReadKey($true).Key
    if ($key_input -ne [System.ConsoleKey]::Enter) {
        Write-Host "$PREFIX Action canceled." -ForegroundColor Red
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

    $timespan = Convert-TimeArgs
    if ($timespan.TotalSeconds -le 0) {
        Write-Host "$PREFIX Invalid time span of $($timespan.TotalSeconds) seconds. I can't move files from the future!" -ForegroundColor Red
        return
    }

    $reference_time = (Get-Date).Add(-$timespan)
    $time_ago = Format-TimeAgo $timespan
    Write-Host "$PREFIX Downloads: Filtering files after $reference_time ($time_ago ago)..." -ForegroundColor Yellow
    $new_items = Get-ChildItem -Path $downloads | Where-Object { $_.CreationTime -gt $reference_time } 

    # learning note: apparently literals should be on the LHS
    if ($null -eq $new_items) {
        Write-Host "$PREFIX Downloads: No files after $reference_time ($time_ago ago)!" -ForegroundColor Red
        return
    }
    Write-Host "$PREFIX Downloads: Found the following ($($new_items.Length)) files:" -ForegroundColor Yellow
    # Format-Table returns an Object[] that needs to be decoded before printing
    $new_items | Format-Table -Property Name, CreationTime | Out-String | Write-Host

    Confirm-PasteAction $new_items.Length
}

# I like compartmentalizing my code, deal with it
Start-MyScript