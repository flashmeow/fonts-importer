# Load test helpers
load 'libs/bats-support/load'
load 'libs/bats-assert/load'
load 'libs/bats-file/load'
load 'libs/helpers'

# Set script name
export SCRIPT="./import-fonts.sh"

#Set setup and teardown functions
setup() {
	setupEnv
}
teardown() {
	teardownEnv
}

@test "Make sure we can find the test files" {
	count="$(find "$REAL_FILE_DIRECTORY" -name '*.ttf' | wc -l)"
	[ $count -gt 0 ]
}




#TODO Add tests for try run. Requires implementation of file tests first
#TODO Add test for -f flag, see if files are overwritten
