# contextmenu.ps1
# A simplified version of downloads.ps1 to be registered in the Windows
# Registry Editor. It uses the default condition of 5 minutes and
# instantly moves matching files from Downloads into current directory.

$TIMESPAN = New-TimeSpan -Minutes 5

function Move-RecentItems {
    param (
        [Parameter(Mandatory = $true)]
        [System.Object[]] $RecentItems
    )
    $cwd = Get-Location
    foreach ($item in $RecentItems) {
        $new_path = "$($cwd.ToString())\$($item.Name)"
        $item.MoveTo($new_path)
    }
    # Debugging, shouldn't show up when run from context menu
    Write-Host "$PREFIX Moved $($RecentItems.Length) items to $cwd." -ForegroundColor Green
}

$downloads = (New-Object -ComObject Shell.Application).NameSpace('shell:Downloads').Self.Path
$reference_time = (Get-Date).Add(-$TIMESPAN)
$new_items = Get-ChildItem -Path $downloads | Where-Object { $_.CreationTime -gt $reference_time }

if ($null -ne $new_items) {
    Move-RecentItems -RecentItems $new_items
}

exit 0
