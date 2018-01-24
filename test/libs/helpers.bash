setupEnv() {
	SOURCE_DIRECTORY="$(mktemp -d)"
	export SOURCE_DIRECTORY
	TARGET_DIRECTORY="$(mktemp -d)"
	export TARGET_DIRECTORY
}

teardownEnv() {
	rm -rf "$SOURCE_DIRECTORY"
	rm -rf "$TARGET_DIRECTORY"
}
