#!/bin/bash
#===============================================================================
#
#          FILE: import-fonts.sh
#
#         USAGE: ./import-fonts.sh
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
			return 4
		fi
	fi
	DESTINATION_FOLDER=~/.fonts
	return 0
}


#-------------------------------------------------------------------------------
# Verification of source directory
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# Verification of source directory
#-------------------------------------------------------------------------------
if [ -z "$SOURCE_PARENT_FOLDER" ]; then
	echo "Error 1: you must provide a source directory. Exiting."
fi

if [ ! -d "$SOURCE_PARENT_FOLDER" ]; then
	echo "Error 2: Source folder does not exist. Exiting."
	exit 2
fi

if [ ! -r "$SOURCE_PARENT_FOLDER" ]; then
	echo "Error 3: User does not have read permission for the source folder. Exiting."
	exit 3
fi


#-------------------------------------------------------------------------------
# Verification of destination directory
#-------------------------------------------------------------------------------

DESTINATION_FOLDER=${2}

if [ -z "$DESTINATION_FOLDER" ]; then	# If the destination is unset, default to ~/.fonts, and create if if necessary.
	set_dotfonts_folder
	return_status=$?
	if [ "$return_status" -ne "0" ]; then
		if [ "$return_status" -eq "4" ]; then
			echo "Error 4: User does not have write permission to the home folder, cannot create \"~/.fonts\". Exiting."
			exit 4
		fi
	fi

else	# Make sure user has write permission to the specified destination folder
	if [ ! -d "$DESTINATION_FOLDER" ]; then
		echo "$DESTINATION_FOLDER does not exist. Would you like to create it? [y/n]"
		read create_destination_folder
		if [ "${create_destination_folder,,}" = "y" ]; then
			# Verify we can create the directory
			if [ -w "$(dirname "$DESTINATION_FOLDER")" ]; then
				mkdir "$DESTINATION_FOLDER"
			else
				echo "Cannot create \"$DESTINATION_FOLDER\". Would you like to use \"~/.fonts\" instead? [y/N]"
				read use_fonts
				if [ "${use_fonts,,}" = "y" ]; then
					set_dotfonts_folder
					return_status=$?
					if [ "$return_status" -ne "0" ]; then
						if [ "$return_status" -eq "4" ]; then
							echo "Error 4: User does not have write permission to the home folder, cannot create \"~/.fonts\". Aborting."
							exit 4
						fi
					fi
				else
					echo "Error 5: User does not have write permission for \"$(dirname "$DESTINATION_FOLDER")\". Aborting"
					exit 5
				fi
			fi
		fi
	fi

	if [ ! -w "$DESTINATION_FOLDER" ]; then
		echo "Error 4: User does not have write permission for \"$DESTINATION_FOLDER\" Exiting."
		exit 4
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

find "$SOURCE_PARENT_FOLDER" \( -name '*.ttf' -o -name '*.otf' -o -name '*.ttc' \) -exec cp '{}' "$DESTINATION_FOLDER" \;


#-------------------------------------------------------------------------------
# Remind user to restart the font cache
#-------------------------------------------------------------------------------
echo -e "Done.\nPlease restart or run fc-cache to start using the fonts\n"

