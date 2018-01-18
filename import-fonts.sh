#!/bin/bash


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

# Verification of source directory

SOURCE_PARENT_FOLDER=${1}

if [ ! -d "$SOURCE_PARENT_FOLDER" ]; then
echo "Error 1: Source folder does not exist. Aborting."
exit 1
fi

if [ ! -r "$SOURCE_PARENT_FOLDER" ]; then
echo "Error 2: User does not have read permission for the source folder. Aborting."
exit 2
fi

# Verification of destination directory

DESTINATION_FOLDER=${2}

if [ -z "$DESTINATION_FOLDER" ]; then	# If the destination is unset, default to ~/.fonts, and create if if necessary.
	set_dotfonts_folder
	return_status=$?
	if [ "$return_status" -ne "0" ]; then
		if [ "$return_status" -eq "4" ]; then
			echo "Error 4: User does not have write permission to the home folder, cannot create \"~/.fonts\". Aborting."
			exit 4
		fi
	fi

else	# Make sure user has write permission to the specified destination folder
	if [ ! -d "$DESTINATION_FOLDER" ]; then
		echo "$DESTINATION_FOLDER does not exist. Would you like to create it? [y/n]"
		read create_destination_folder
		if [ "${create_destination_folder,,}" = "y" ]; then
			if [ -w "$(dirname "$DESTINATION_FOLDER")" ]; then	# Verify we can create the directory
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
	echo "Error 3: User does not have write permission for the destination folder. Aborting."
	exit 3
	fi
fi

# Find all files with a .dfont extension and convert them to .tff. Creates a temp folder in the destination for the fondued files. TODO: Verify fondu is installed, skip this if it is not. See https://linuxconfig.org/how-to-test-for-installed-package-using-shell-script-on-ubuntu-and-debian

# Enable globstar
shopt -s globstar

dfont_counter=0
# Count number of .dfont files in source directory and subdirectories
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

