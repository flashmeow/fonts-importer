#!./test/libs/bats/bin/bats

# Load test helpers
load 'libs/bats-support/load'
load 'libs/bats-assert/load'
load 'libs/helpers'

# Set script name
export SCRIPT="./import-fonts.sh"

# Set setup and teardown functions
setup() {
	setupEnv
}
teardown() {
	teardownEnv
}

@test "Check that source directory is specified" {
	run ${SCRIPT}
	assert_failure 2
}

@test "Check that source directory is specified, even with other flags" {
	run ${SCRIPT} -t "$TARGET_DIRECTORY"
	assert_failure 2
}

@test "Check that the source is a directory" {
	run ${SCRIPT} -s /bin/bash
	assert_failure 3
}

@test "Check that the source is readable" {
	# Create unreadable directory
	unreadable_directory="$(mktemp -d)"
	chmod -r "$unreadable_directory"

	run ${SCRIPT} -s "$unreadable_directory"
	assert_failure 4

	rmdir "$unreadable_directory"
}

@test "Check that destination is writable" {
	# Create unwritable directory
	unwritable_directory="$(mktemp -d)"
	chmod -w "$unwritable_directory"

	run ${SCRIPT} -s "$SOURCE_DIRECTORY" -t "$unwritable_directory"
	assert_failure 5

	rmdir "$unwritable_directory"
}

@test "When creating a destination directory, make sure the parent directory is writable" {
	# Create parent directory
	unwritable_directory="$(mktemp -d)"
	chmod -w "$unwritable_directory"

	run ${SCRIPT} -c -s "$SOURCE_DIRECTORY" -t "$unwritable_directory"/child_directory
	assert_failure 6

	rmdir "$unwritable_directory"
}

@test "Missing -c flag when destination is non-existent" {
	run ${SCRIPT} -s "$SOURCE_DIRECTORY" -t "$TARGET_DIRECTORY"/non_existent_directory
	assert_failure 7
}

#TODO Add test for set_dotfonts_directory, no write permission to ~/.fonts
#TODO Add test for -f flag, see if files are overwritten
