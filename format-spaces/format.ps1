<#
.Synopsis
   Formats delimiters of file names.
.DESCRIPTION
   To be used from the context menu. Upon running this script, standardizes the delimitation of words in the names of the files in the current directory.
#>

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

exit 0
