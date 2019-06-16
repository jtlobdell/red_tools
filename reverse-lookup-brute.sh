#!/bin/bash
trap 'exit' INT

function print_usage {
        echo "Usage: $0 ip_octets dns_server"
        echo -e "\tip_octets - first three octects of the ip range"
        echo -e "\texample: $0 10.11.1 10.11.1.220"
	echo -e "\t\tconduct reverse lookup brute force sweep on addresses 10.11.1.1-254 with dns 10.11.1.220"
        exit 1
}

if [[ $# -ne 2 ]]; then
	print_usage
fi

# add a . at the end if it's n ot there
if [[ "$1" != *. ]]; then
	net="$1."
else
	net="$1"
fi

dns=$2

echo "Running reverse lookup brute force on IP range $net(1-254) with dns $dns"

# do the ping sweep
for i in `seq 254`; do
	host $net$i $dns | tail -n 1 | grep -v "NXDOMAIN" \
	| awk -F '[. ]' \
	  '{ printf $4"."$3"."$2"."$1" "; for (i=10;i<=NF;++i) printf $i"."; printf "\n"}' \
	| sed 's/..$//'
done
