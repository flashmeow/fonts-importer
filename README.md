# fonts-importer [![Build Status](https://travis-ci.org/flashmeow/fonts-importer.svg?branch=master)](https://travis-ci.org/flashmeow/fonts-importer) [![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
fonts-importer is a command-line utility to transfer font files in many folders to a single destination folder.

## Installation
Download the latest [release](https://github.com/flashmeow/fonts-importer/releases/latest).

## Usage
`./fonts-importer.sh -s SOURCE_DIRECTORY -t TARGET_DIRECTORY`

* `SOURCE_DIRECTORY` is the root folder for searching for font files.
* `TARGET_DIRECTORY` is the destination folder for the font files.

## Contributing
Clone the repository and its testing submodules with `git clone --recursive git://github.com/flashmeow/fonts-importer.git`.

If you've already cloned the repository with out the submodules, run `git submodule update --init --recursive` inside the repository's directory to download them.
