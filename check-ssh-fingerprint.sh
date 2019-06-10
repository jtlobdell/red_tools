#!/bin/bash

# Use this in conjunction with SSH Bad Keys:
# https://github.com/rapid7/ssh-badkeys
# The repo doesn't include fingerprints (which this checker uses).
# To generate the fingerprints, use generate-fingerprints.sh
# Change the file grep searches to the generated fingerprints file.

if [[ $# -lt 1 ]]; then
	echo "Checks SSH keys against known bad keys"
	echo "Usage: $0 KEY_1 [... KEY_N]"
	exit 1
fi

for KEY in "$@"
do
	grep "$KEY" ~/share/ssh-badkeys/fingerprints.txt
done
