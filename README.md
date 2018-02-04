# fonts-importer
fonts-importer is a command-line utility to transfer font files in many folders to a single destination folder.

## Installation
Download the latest [release](https://github.com/flashmeow/fonts-importer/releases/latest).

## Usage
`./import-fonts -s SOURCE_DIRECTORY -t TARGET_DIRECTORY`

* `SOURCE_DIRECTORY` is the root folder for searching for font files.
* `TARGET_DIRECTORY` is the destination folder for the font files.

## Contributing
Clone the repository and its testing submodules with `git clone --recursive git://github.com/flashmeow/fonts-importer.git`

If you've already cloned the repository with out the submodules, run `git submodule update --init --recursive` inside the repository's directory to download them 