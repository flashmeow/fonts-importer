#!/bin/bash
#===============================================================================
#
#          FILE: import-fonts.sh
#
#         USAGE: ./import-fonts.sh [-cfv] -s SOURCE_DIRECTORY [-t DESTINATION_FOLDER]
#
#   DESCRIPTION: Copies font files from a source to a destination folder. Also converts .dfont files to .tff on the fly
#
#       OPTIONS: None
#  REQUIREMENTS: fondu, for converting .dfont files. Not needed otherwise
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: flashmeow
#       CREATED: 01/19/2018 14:26
#      REVISION: 2
#===============================================================================


#---  FUNCTION  ----------------------------------------------------------------
#          NAME:  set_dotfonts_folder
#   DESCRIPTION:  Sets the destination folder (DESTINATION_FOLDER) to ~/.fonts. Tries to create if it doesn't exist
#    PARAMETERS:  None
#       RETURNS:  0 if success, 4 if no write permission to ~/.fonts
#-------------------------------------------------------------------------------
function set_dotfonts_folder() {
	if [ ! -d ~/.fonts ]; then
		# Make sure we can create the folder
		if [ -w ~/ ]; then
			mkdir ~/.fonts
		else
			# We cannot make the file, return error code 4
			echo "Error 5: User does not have write permission to the home folder, cannot create \"~/.fonts\". Exiting."
			exit 5
		fi
	fi

	DESTINATION_FOLDER=~/.fonts
}


#---  FUNCTION  ----------------------------------------------------------------
#          NAME: get_help
#   DESCRIPTION: Prints a help message
#    PARAMETERS: None
#       RETURNS: None
#-------------------------------------------------------------------------------
function get_help() {
	cat << EOF
	Usage: ${0##*/} [-cfv] -s SOURCE_DIRECTORY [-t DESTINATION_FOLDER]
	Copy fonts from the SOURCE_DIRECTORY to the DESTINATION_FOLDER. If no DESTINATION_FOLDER is specified, copy files to ~/.fonts

	-h			shows this message and exits
	-t DESTINATION_FOLDER 	copy fonts to the specified folder
	-f			force overwriting of existing font files
	-c			create the destination folder if it doesn't exits
	-v			verbose mode

EOF
exit 0
}


#-------------------------------------------------------------------------------
# GETOPTS flag handling
#-------------------------------------------------------------------------------
# Variables
verbose=0
force=0
create_destination_folder=0

# GETOPTS
while getopts "s:t:fcvh" opt; do
	case $opt in
		s)	SOURCE_PARENT_FOLDER=$OPTARG;;
		t)	DESTINATION_FOLDER=$OPTARG;;
		f)	force=1;;
		c)	create_destination_folder=1;;
		v)	verbose=1;;
		h)	get_help;;
		*)	echo "Invalid option: -$OPTARG" >&2; get_help;;
	esac
done


#-------------------------------------------------------------------------------
# Verification of source directory
#-------------------------------------------------------------------------------
if [ -z "$SOURCE_PARENT_FOLDER" ]; then
	echo "Error 2: You must provide a source directory. Exiting."
	exit 2
fi

if [ ! -d "$SOURCE_PARENT_FOLDER" ]; then
	echo "Error 3: Source is not a directory. Exiting."
	exit 3
fi

if [ ! -r "$SOURCE_PARENT_FOLDER" ]; then
	echo "Error 4: User does not have read permission for the source directory. Exiting."
	exit 4
fi


#-------------------------------------------------------------------------------
# Verification of destination directory
#-------------------------------------------------------------------------------

if [ -z "$DESTINATION_FOLDER" ]; then	# If the destination is unset, default to ~/.fonts, and create if if necessary.
	set_dotfonts_folder

else
	if [ ! -d "$DESTINATION_FOLDER" ]; then		# Directory doesn't exist yet
		if [ $create_destination_folder = 1 ]; then
			if [ -w "$(dirname "$DESTINATION_FOLDER")" ]; then	# Check for write permissions in the parent of the destination directory
				mkdir "$DESTINATION_FOLDER"
			else
				echo "Error 6: User does not have write permission for \"$(dirname "$DESTINATION_FOLDER")\". Exiting."
				exit 6
			fi
		else
			echo "Error 7: $DESTINATION_FOLDER is not an existing folder. Use the -c flag to create it. Exiting."
			exit 7
		fi
	fi

	if [ ! -w "$DESTINATION_FOLDER" ]; then
		echo "Error 5: User does not have write permission for \"$DESTINATION_FOLDER\" Exiting."
		exit 5
	fi
fi


#-------------------------------------------------------------------------------
# Convert .dfont files to .ttf files
#-------------------------------------------------------------------------------

# Globstar is enabled to allow for recursive searching
shopt -s globstar

# Count number of .dfont files in source directory and subdirectories
dfont_counter=0
for file in "$SOURCE_PARENT_FOLDER"/**/*.dfont; do
	((dfont_counter++))
	if [ $verbose -gt 0 ]; then
		echo "Counted $dfont_counter .dfont files"
	fi
done

if [ "$dfont_counter" -gt 0 ]; then
	if fondu; then			# Make sure fondu is installed. Will return error 127 if not installed
		TEMP_FOLDER=$(mktemp -d)	# Create temp folder so nothing is changed. May not work on macs, see https://unix.stackexchange.com/questions/30091/fix-or-alternative-for-mktemp-in-os-x
		for file in "$SOURCE_PARENT_FOLDER"/**/*.dfont; do	# Whitespace-safe and recusive search for .dfont files
			filename=$(basename "$file" .dfont)
			if [ ! -e "$filename".tff ]; then	# Sees if file has already been converted, otherwise convert file
				(
				cd "$TEMP_FOLDER"
				fondu -force "$file"
				cp "$filename".ttf "$DESTINATION_FOLDER"
				rm ./*
				)
			fi
		done
		rm -R "$TEMP_FOLDER"
	else
		echo "Fondu is not installed. Please install it through your package manager. Skipping .dfont files."
	fi
fi


#-------------------------------------------------------------------------------
# Find all files with font extentions and copy them to the destination folder
#-------------------------------------------------------------------------------

if [ $force -eq 0 ]; then
	find "$SOURCE_PARENT_FOLDER" \( -name '*.ttf' -o -name '*.otf' -o -name '*.ttc' \) -exec cp -n '{}' "$DESTINATION_FOLDER" \;
else
	find "$SOURCE_PARENT_FOLDER" \( -name '*.ttf' -o -name '*.otf' -o -name '*.ttc' \) -exec cp '{}' "$DESTINATION_FOLDER" \;
fi


#-------------------------------------------------------------------------------
# Remind user to restart the font cache
#-------------------------------------------------------------------------------
echo -e "Done.\nPlease restart or run fc-cache to start using the fonts\n"

