#!/usr/bin/env python3
# -*- coding: utf-8 -*-
r"""update_readme.py

Script to run before a commit. Updates the root README.md document to
include links to the subdirectories.

Paste the following content into .git/hooks/pre-commit:

#!C:/Progra~1/Git/usr/bin/sh.exe
# Update README.md
python ".\update_readme.py"
if [ $? -eq 0 ]; then
    echo "pre-commit (README): OK"
    # Stage the affected file in case it was updated
    git add ".\README.md"
else
    echo "pre-commit (README): FAIL"
    exit 1
fi
"""

from pathlib import Path

# Assert that script is run starting at the project root
assert Path.cwd() == Path(__file__).parent

print("Running update_readme.py...")

# List of names of directories at the root to exclude.
EXCLUDE = [
    ".git",
    "PS-profile",
    "test",
]

# Path to the README.md document to update.
ROOT_README = Path("README.md")

# Markdown template
markdown = """\
# scripts

This repository includes a collection of simple PowerShell scripts that
I've written to automate certain tasks. Most of these also come with
installation instructions for if you, a lucky passerby, want to make
your Windows workflow just a bit more convenient too!

Check them out here:

{links}

I also linked this repository to my
[PowerShell profile script backup](https://github.com/vinlin24/PS-profile)
since I thought it seemed relevant. There you can see the kind of
convenience functions I've written to improve my own command line
workflow!
"""

# Populate the links placeholder

buffer = ""
for file in Path.cwd().iterdir():
    if not file.is_dir() or file.name in EXCLUDE:
        continue

    # Extract the program's name from its README
    readme = file / "README.md"
    with open(readme, "rt", encoding="utf-8") as fp:
        header = fp.readline().strip()
    program_name = header.removeprefix("# ")

    # Markdown bulleted list
    buffer += f"- [{program_name}]({file.name})\n"

buffer = buffer or "- Nothing yet, sit tight!\n"
markdown = markdown.format(links=buffer)

# Write to the root README
with open(ROOT_README, "wt", encoding="utf-8") as fp:
    fp.write(markdown)

print("Finished running update_readme.py.")
