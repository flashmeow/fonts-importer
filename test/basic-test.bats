#!/usr/bin/env/bats

@test "Basic addition test" {
	result="$(echo 2+2 | bc)"
	[ "$result" -eq 4 ]
}
