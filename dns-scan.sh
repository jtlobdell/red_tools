#!/bin/bash
trap 'exit' INT

function print_usage {
        echo "Usage: $0 ip_octets"
        echo -e "\tip_octets - first three octects of the ip range"
        echo -e "\texample: $0 10.11.1"
	echo -e "\t\tsearch for dns on addresses 10.11.1.1-254"
        exit 1
}

if [[ $# -ne 1 ]]; then
	print_usage
fi

# add a . at the end if it's not there
if [[ "$1" != *. ]]; then
	net="$1."
else
	net="$1"
fi

echo "Checking hosts in range ${net}1-254 for open port 53 (DNS). Go smoke a cigarette."

# scan each host
for i in `seq 254`; do
	nmap -Pn -oG - -p 53 -T2 ${net}$i | grep '53/open' | awk '{ print $2 }'
done | sort -n -t . -k 4
