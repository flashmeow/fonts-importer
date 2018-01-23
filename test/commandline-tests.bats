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

# TODO pass other flags

@test "Check that the source is a directory" {
		run ${SCRIPT} -s /bin/bash
	assert_failure 3
}

@test "Check that the source is readable" {
	# Create unreadable folder
	unreadable_directory="$(mktemp -d)"
	chmod -r "$unreadable_directory"

	run ${SCRIPT} -s "$unreadable_directory"
	assert_failure 4

	rmdir "$unreadable_directory"
}

@test "Check that destination is writable" {
	# Create unwritable folder
	unwritable_directory="$(mktemp -d)"
	chmod -w "$unwritable_directory"

	run ${SCRIPT} -s "$SOURCE_DIRECTORY" -t "$unwritable_directory"
	assert_failure 5

	rmdir "$unwritable_directory"
}
