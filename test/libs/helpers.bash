setupEnv() {
	# Get current path, go up two directories, and enter src/fonts for test files
	current_path=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
	font_directory_path=${current_path%/*}/src/fonts
	REAL_FILE_DIRECTORY="$font_directory_path"
	export REAL_FILE_DIRECTORY

	REAL_TARGET_DIRECTORY=${current_path%/*}/src/destination
	export REAL_TARGET_DIRECTORY

	SOURCE_DIRECTORY="$(mktemp -d)"
	export SOURCE_DIRECTORY

	TARGET_DIRECTORY="$(mktemp -d)"
	export TARGET_DIRECTORY
}

teardownEnv() {
	rm -rf "$SOURCE_DIRECTORY"
	rm -rf "$TARGET_DIRECTORY"
}
