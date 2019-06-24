#!/bin/bash

if [[ $# -lt 1 ]]; then
	echo "Checks SSH keys against known bad keys"
	echo "Usage: $0 KEY_1 [... KEY_N]"
	exit 1
fi

for KEY in "$@"
do
	grep "$KEY" ~/share/ssh-badkeys/fingerprints.txt
	matches=$(ls -1R ~/share/debian-ssh/ | grep `echo $KEY | sed "s/://g"`)
	for m in $matches; do
		find ~/share/debian-ssh/ -name $m
	done
done
