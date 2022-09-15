# Downloads Paster

![OS](https://img.shields.io/badge/Windows-10%2C%2011-blue)
![PowerShell](https://img.shields.io/badge/PowerShell-5%2B-blue)

## Description

This simple PowerShell script takes all files created 5 minutes ago or newer from the Downloads directory and moves them to the current directory.

This was motivated by common use cases in my day-to-day-life:

- Downloading from a browser and some apps puts files in the Downloads folder by default.
- Downloading things on-the-fly without thinking of where I'll put them yet.

## Installation

1. Download [paster.ps1](paster.ps1).
2. Place it wherever you want, but preferably somewhere it won't move much, or you'll have to repeat Step 3 when it does.
3. Run the script with the `-Register` switch:
   
   ```powershell
   path\to\paster.ps1 -Register
   ```
   The script should now be ready for use from the context menu:

<p align="center">
   <img width="200" src="preview.png">
</p>

## Further

[downloads.ps1](downloads.ps1) is a more versatile command-line version of contextmenu.ps1. You can convert it to a PowerShell module and install it to use it anywhere you have your terminal open, though I have not tried this nor tested it myself yet.

Syntax:
```powershell
downloads.ps1 [[-Seconds] <int>] [[-Minutes] <int>] [[-Hours] <int>] [[-Days] <int>] [-Default]
```
The time arguments exactly match those of the built-in cmdlet [New-TimeSpan](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/new-timespan?view=powershell-7.2), and they customize how far back in time the script should look for files in the Downloads folder. This script also lists the files it is about to move and prompts for confirmation before proceeding.

## Limitations

Running the script from the context menu causes a window to briefly pop up, even with the `-WindowStyle Hidden` option to `powershell.exe`. This [seems to be a limitation](https://stackoverflow.com/questions/1802127/how-to-run-a-powershell-script-without-displaying-a-window) when running scripts in this manner.
