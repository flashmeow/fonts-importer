#!/bin/bash

SOURCE_PARENT_FOLDER=${1}

if [ ! -d "$SOURCE_PARENT_FOLDER" ]; then
echo "Error -1: Source folder does not exist"
exit -1
fi

if [ ! -r "$SOURCE_PARENT_FOLDER" ]; then
echo "Error -2: User does not have read permission for the source folder"
exit -2
fi

DESTINATION_FOLDER=${2}		# Might use ${2:~/.fonts} for default, but no handling for if ~/.fonts doesn't exist

if [ -z "$DESTINATION_FOLDER" ]; then	# If the destination is unset, default to ~/.fonts, and create if if necessary.
	if [ ! -d ~/.fonts ]; then
		if [ -w ~/ ]; then
			mkdir ~/.fonts
			DESTINATION_FOLDER=~/.fonts
		else
			echo "Error -4: User does not have write permission to the home folder"
			exit -4
		fi
	fi

	DESTINATION_FOLDER=~/.fonts

else	# Make sure user has write permission to the specified destination folder
	if [ ! -d "$DESTINATION_FOLDER" ]; then
		echo "$DESTINATION_FOLDER does not exist. Would you like to create it? [y/n]"
		read create_destination_folder
		if [ "${create_destination_folder,,}" = "y" ]; then
			if [ -w "$(dirname "$DESTINATION_FOLDER")" ]; then
				mkdir "$DESTINATION_FOLDER"
			else
				echo "Would you like to use \"~/.fonts\"? [y/N]"
				read use_fonts
				if [ "${use_fonts,,}" = "y" ]; then
					if [ -w ~/ ]; then
						mkdir ~/.fonts
						DESTINATION_FOLDER=~/.fonts
					else
						echo "Error -4: User does not have write permission to the home folder, cannot create \"~/.fonts\"."
						exit -4
					fi
				else
					echo "Aborted."
					exit 1
				fi

				echo "Error -5: User does not have write permission for \"$(dirname "$DESTINATION_FOLDER")\""
			fi

		fi
	fi

	if [ ! -w "$SOURCE_PARENT_FOLDER" ]; then
	echo "Error -3: User does not have write permission for the destination folder"
	exit -3
	fi
fi

# Find all files with a .dfont extension and convert them to .tff. Creates a temp folder in the destination for the fondued files. TODO: Verify fondu is installed, skip this if it is not. See https://linuxconfig.org/how-to-test-for-installed-package-using-shell-script-on-ubuntu-and-debian

# Enable globstar
shopt -s globstar

dfont_counter=0
# See if there are any .dfont files
for file in "$SOURCE_PARENT_FOLDER"/**/*.dfont; do
	((dfont_counter++))
done

if [ "$dfont_counter" -gt 0 ]; then
	TEMP_FOLDER=$(mktemp -d)	# Create temp folder so nothing is changed. May not work on macs
	for file in "$SOURCE_PARENT_FOLDER"/**/*.dfont; do	# Whitespace-safe and recusive
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
fi

# Find all files with font extentions and copy them to the destination folder
find "$SOURCE_PARENT_FOLDER" \( -name '*.ttf' -o -name '*.otf' -o -name '*.ttc' \) -exec cp '{}' "$DESTINATION_FOLDER" \;

# Remove temp folder
rm -rf "$TEMP_FOLDER"

echo -e "\nDone copying!"

echo -e "\nWould you like to restart the font cache? [y/N]"

read should_restart_cache

if [ "${should_restart_cache,,}" = "y" ]; then		# 2 commas convert to lowercase
	echo -e "Restarting the font cache"
	# Restart the font cache to use the fonts immediately
	fc-cache -f
	echo -e "\nDone!"
else echo -e "\nPlease restart or run fc-cache to start using the fonts\n"
fi

