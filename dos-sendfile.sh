#!/bin/bash

function print_usage {
	echo "$0 - Prepares a file to be uploaded through echo statements in a DOS terminal"
	echo "Usage: $0 input_file write_file"
	echo "	input_file - file to upload"
	echo "	write_file - file to write to on target"
}

if [[ $# -ne 2 ]]; then
	print_usage
	exit 1
fi

IFS=$'\n'

escaped_file=$(for line in `cat $1`; do echo $line | sed "s/(/^(/g" | sed "s/)/^)/g" | sed "s/</^</g" | sed "s/>/^>/g" | sed "s/|/^|/g"; done)
for line in $escaped_file; do echo "echo $line >>$2"; done
