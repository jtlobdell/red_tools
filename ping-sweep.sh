#!/bin/bash
trap 'exit' INT

function print_usage {
        echo "Usage: $0 [-t ttl] ip_octets"
        echo -e "\tip_octects - first three octects of the ip range"
	echo -e "\t-t ttl - ttl to use with ping"
        echo -e "\texample: $0 -t 3 10.11.1"
	echo -e "\t\tconduct ping sweep on addresses 10.11.1.1-254 with ttl of 3"
        exit 1
}

if [[ $# -lt 1 ]]; then
	print_usage
fi
if [[ $# -gt 3 ]]; then
	print_usage
fi
if [[ $# -eq 2 ]]; then
	print_usage
fi

ttl=3
if [[ $# -eq 3 ]]; then
	if [[ "$1" == "-t" ]]; then
		ttl=$2
		shift
		shift
	else
		print_usage
	fi
fi

# add a . at the end if it's n ot there
if [[ "$1" != *. ]]; then
	net="$1."
else
	net="$1"
fi

echo "Running ping sweep with ttl of $ttl and IP range of $net(1-254)"

# do the ping sweep
for i in `seq 254`; do
	ping -c 1 -w 2 $net$i | grep from | cut -d " " -f 4 | sed 's/://' &
done | sort -n -t . -k 4
