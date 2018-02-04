#!/bin/bash
#===============================================================================
#
#          FILE: fonts-importer.sh
#
#         USAGE: ./fonts-importer.sh [-cfv] -s SOURCE_DIRECTORY [-t DESTINATION_DIRECTORY]
#
#   DESCRIPTION: Copies font files from a source to a destination directory. Also converts .dfont files to .tff on the fly
#
#       OPTIONS: None
#  REQUIREMENTS: fondu, for converting .dfont files. Not needed otherwise
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: flashmeow
#       CREATED: 01/19/2018 14:26
#      REVISION: 2.2
#===============================================================================


#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  set_dotfonts_directory
#   DESCRIPTION:  Sets the destination directory (DESTINATION_DIRECTORY) to ~/.fonts. Tries to create if it doesn't exist
#    PARAMETERS:  None
#       RETURNS:  0 if success, 4 if no write permission to ~/.fonts
#-------------------------------------------------------------------------------
function set_dotfonts_directory() {
	if [ ! -d ~/.fonts ]; then
		# Make sure we can create the directory
		if [ -w ~/ ]; then
			if [ "$dry_run" == 0 ]; then
				mkdir ~/.fonts
			else:
				echo "Would create ~/.fonts, but this is a dry run."
			fi
		else
			# We cannot make the file, return error code 4
			echo "Error 5: User does not have write permission to the home directory, cannot create \"~/.fonts\". Exiting."
			exit 5
		fi
	fi

	DESTINATION_DIRECTORY=~/.fonts
}


#---  FUNCTION  ----------------------------------------------------------------
#          NAME: get_help
#   DESCRIPTION: Prints a help message
#    PARAMETERS: None
#       RETURNS: None
#-------------------------------------------------------------------------------
function get_help() {
	cat << EOF
	Usage: ./${0##*/} [-cfvd] -s SOURCE_DIRECTORY [-t DESTINATION_DIRECTORY]
	Copy fonts from the SOURCE_DIRECTORY to the DESTINATION_DIRECTORY. If no DESTINATION_DIRECTORY is specified, copy files to ~/.fonts

	-h				shows this message and exits
	-t DESTINATION_DIRECTORY 	copy fonts to the specified directory
	-f				force overwriting of existing font files
	-c				create the destination directory if it doesn't exits
	-v				verbose mode
	-d				dry run. will not copy any files or make any directories

EOF
exit 0
}

#-------------------------------------------------------------------------------
# Show help if no arguments are given
#-------------------------------------------------------------------------------
if [ $# -eq 0 ]; then
	get_help
	exit 0
fi

#-------------------------------------------------------------------------------
# GETOPTS flag handling
#-------------------------------------------------------------------------------
# Variables
verbose=0
force=0
create_destination_directory=0
dry_run=0

# GETOPTS
while getopts "s:t:fcvhd" opt; do
	case $opt in
		s)	SOURCE_PARENT_DIRECTORY=$OPTARG;;
		t)	DESTINATION_DIRECTORY=$OPTARG;;
		f)	force=1;;
		c)	create_destination_directory=1;;
		v)	verbose=1;;
		d)	dry_run=1;;
		h)	get_help;;
		*)	echo "Invalid option: -$OPTARG" >&2; get_help;;
	esac
done


#-------------------------------------------------------------------------------
# Verification of source directory
#-------------------------------------------------------------------------------
if [ -z "$SOURCE_PARENT_DIRECTORY" ]; then
	echo "Error 2: You must provide a source directory. Exiting."
	exit 2
fi

if [ ! -d "$SOURCE_PARENT_DIRECTORY" ]; then
	echo "Error 3: Source is not a directory. Exiting."
	exit 3
fi

if [ ! -r "$SOURCE_PARENT_DIRECTORY" ]; then
	echo "Error 4: User does not have read permission for the source directory. Exiting."
	exit 4
fi


#-------------------------------------------------------------------------------
# Verification of destination directory
#-------------------------------------------------------------------------------

if [ -z "$DESTINATION_DIRECTORY" ]; then	# If the destination is unset, default to ~/.fonts, and create if if necessary.
	set_dotfonts_directory

else
	if [ ! -d "$DESTINATION_DIRECTORY" ]; then		# Directory doesn't exist yet
		if [ $create_destination_directory == 1 ]; then
			if [ -w "$(dirname "$DESTINATION_DIRECTORY")" ]; then	# Check for write permissions in the parent of the destination directory
				if [ "$dry_run" == 0 ]; then
					mkdir "$DESTINATION_DIRECTORY"
				else
					echo "Would create $DESTINATION_DIRECTORY, but this is a dry run"
				fi
			else
				echo "Error 6: User does not have write permission for \"$(dirname "$DESTINATION_DIRECTORY")\". Exiting."
				exit 6
			fi
		else
			echo "Error 7: $DESTINATION_DIRECTORY is not an existing directory. Use the -c flag to create it. Exiting."
			exit 7
		fi
	fi

	if [ ! -w "$DESTINATION_DIRECTORY" ]; then
		echo "Error 5: User does not have write permission for \"$DESTINATION_DIRECTORY\" Exiting."
		exit 5
	fi
fi


#-------------------------------------------------------------------------------
# Convert .dfont files to .ttf files
#-------------------------------------------------------------------------------


# Count number of .dfont files in source directory and subdirectories
dfont_counter=$(find "$DESTINATION_DIRECTORY" -name '*.dfont' | wc -l)	# Recursive search, wc -l counts the number of lines, with one file per line, counts the number of files
if [ $verbose != 0 ]; then
	find "$DESTINATION_DIRECTORY" -name '*.dfont'	# Without piping, find prints the found files
	echo "Found $dfont_counter .dfont files"
fi

if [ "$dfont_counter" -gt 0 ]; then
	if fondu; then			# Make sure fondu is installed. Will return error 127 if not installed
		if [ $dry_run == 0 ]; then
			TEMP_DIRECTORY=$(mktemp -d)	# Create temp directory so nothing is changed. May not work on macs, see https://unix.stackexchange.com/questions/30091/fix-or-alternative-for-mktemp-in-os-x
		else
			echo "Would create a temp directory, but this is a dry run."
		fi

		for file in "$SOURCE_PARENT_DIRECTORY"/**/*.dfont; do	# Whitespace-safe and recusive search for .dfont files
			filename=$(basename "$file" .dfont)
			if [ ! -e "$filename".tff ]; then	# Checks if file has already been converted, otherwise convert file
				if [ $dry_run == 0 ]; then
					(
					cd "$TEMP_DIRECTORY"
					fondu -force "$file"
					cp "$filename".ttf "$DESTINATION_DIRECTORY"
					rm ./*
					)
				else
					echo "Would run fondu on $file, but this is a dry run."
				fi

			fi
		done
		if [ $dry_run == 0 ]; then
			rm -R "$TEMP_DIRECTORY"
		else
			echo "Would remove the temp directory, but this is a dry run."
		fi

	else
		echo "Fondu is not installed. Please install it through your package manager. Skipping .dfont files."
	fi
fi


#-------------------------------------------------------------------------------
# Find all files with font extentions and copy them to the destination directory
#-------------------------------------------------------------------------------

if [ $force == 0 ]; then
	if [ $dry_run == 0 ]; then
		find "$SOURCE_PARENT_DIRECTORY" \( -name '*.ttf' -o -name '*.otf' -o -name '*.ttc' \) -exec cp -n '{}' "$DESTINATION_DIRECTORY" \;
	else
		echo "Would copy files to $DESTINATION_DIRECTORY without overwriting, but this is a dry run."
	fi
else
	if [ $dry_run == 0 ]; then
		find "$SOURCE_PARENT_DIRECTORY" \( -name '*.ttf' -o -name '*.otf' -o -name '*.ttc' \) -exec cp '{}' "$DESTINATION_DIRECTORY" \;
	else
		echo "Would copy files to $DESTINATION_DIRECTORY and overwriting files, but this is a dry run."
	fi
fi


#-------------------------------------------------------------------------------
# Remind user to restart the font cache
#-------------------------------------------------------------------------------
echo -e "Done.\nPlease restart or run fc-cache to start using the fonts\n"

