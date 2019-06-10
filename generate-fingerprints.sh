#!/bin/bash

# Generate md5 (old style) host key fingerprints from ssh-badkeys
# See: https://github.com/rapid7/ssh-badkeys
# Run this in the root of the repo or modify the ls line below.

echo > fingerprints.txt

IFS=$'\n'
for f in `ls -1 authorized/*.pub host/*.pub`; do
	echo "$f $(ssh-keygen -E md5 -l -f $f)" >> fingerprints.txt
done
