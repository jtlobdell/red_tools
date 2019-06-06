#!/bin/bash

# to-do:
# --SNMP enumeration

prog_name=$0

function print_usage {
	echo "Usage: $prog_name [options] HOST"
	echo ""
	echo "Options:"
	echo "	--vulns"
	echo "		Run vulnerability scans"
}

if [[ $# -lt 1 ]]; then
	print_usage
	exit 1
fi

# default options
scan_for_vulns=false

# parse options
while [[ "$#" > 1 ]]; do
	case $1 in
		--vulns) scan_for_vulns=true;;
		*) print_usage; exit 1;;
	esac
	shift
done

# last arg --> HOST
HOST=$1

# detected services that can be scanned for vulns
smb_detected=false

# run our scans
echo "[+] Running fast scan of host $HOST"
echo "[+] nmap --top-ports 10 --open -T2 $HOST"
nmap --top-ports 10 --open -T2 $HOST
echo "[+] Running full scan of host $HOST"
echo "[+] unicornscan -mT $HOST:a > unicorn_tcp.txt"
unicornscan -mT $HOST:a > unicorn_tcp.txt
echo "[+] unicornscan -mU $HOST:a > unicorn_udp.txt"
unicornscan -mU $HOST:a > unicorn_udp.txt

# unicornscan output --> comma separated port list
PTCP=$(IFS=$'\n'; for line in `cat unicorn_tcp.txt`; do echo $line | grep -Eo '\[[[:blank:]]*[[:digit:]]*\]' | grep -Eo '[[:digit:]]*' | tr '\n' ','; done | sed 's/,$/\n/')
PUDP=$(IFS=$'\n'; for line in `cat unicorn_udp.txt`; do echo $line | grep -Eo '\[[[:blank:]]*[[:digit:]]*\]' | grep -Eo '[[:digit:]]*' | tr '\n' ','; done | sed 's/,$/\n/')

# Investigate discovered ports with nmap
if [[ $PTCP ]]; then
	echo "[+] nmap -T2 -sV --script banner -p $PTCP $HOST >> scan_details.txt"
	nmap -T2 -sV --script banner -p $PTCP $HOST >> scan_details.txt
else
	echo "[-] No TCP ports found with unicornscan; skipping nmap follow-up"
fi
if [[ $PUDP ]]; then
	echo "[+] nmap -T2 -sV -sU --script banner -p $PUDP $HOST >> scan_details.txt"
	nmap -T2 -sV -sU --script banner -p $PUDP $HOST >> scan_details.txt
else
	echo "[-] No UDP ports found with unicornscan; skipping nmap follow-up"
fi

# Investigate interesting services
if [[ `grep -E "139/tcp|445/tcp" scan_details.txt | grep open | wc -l` -gt 0 ]]; then
	smb_detected=true
	echo "[+] SMB detected. Running enum4linux."
	echo "[+] enum4linux -a -v $HOST > enum4linux.txt"
	enum4linux -a -v $HOST > enum4linux.txt
fi
if [[ `grep -E "113/tcp" scan_details.txt | grep open | wc -l` -gt 0 ]]; then
	echo "[+] ident detected. running ident-user-enum"
	ident_ports=`echo $PTCP | sed 's/,/ /g'`
	echo "[+] ident-user-enum $HOST $ident_ports > ident_enum.txt"
	ident-user-enum $HOST $ident_ports > ident_enum.txt
fi
if [[ `grep -E "20/tcp" scan_details.txt | grep open | wc -l` -gt 0 ]]; then
	echo "[+] ssh detected. running ssh-info.sh"
	echo "[+] ssh-info.sh $HOST > ssh_info.txt"
	ssh-info.sh $HOST > ssh_info.txt
fi

# Conduct vulnerability scans
if [[ "$scan_for_vulns" = true ]]; then
	if [[ "$smb_detected" = true ]]; then
		echo "[+] Scanning for SMB vulns"
		echo "[+] smb_vuln_scans.sh $HOST > vuln_scan_smb.txt"
		smb-vuln-scans.sh $HOST > vuln_scan_smb.txt
	fi
fi

