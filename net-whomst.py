#!/usr/bin/python
import sys
def print_usage():
	print sys.argv[0] + " [tasklist_file netstat_file]"
	print "\tAssociates PIDs with tasks to show what program is using what connection"
	print "\ttasklist_file: text file containining output of tasklist (default tasklist.txt)"
	print "\tnetstat_file: text file containing output of netstat /a /n /o (default netstat.txt)"
	print "\tif one is specifed both must be specified!"
if len(sys.argv) != 1 and len(sys.argv) != 3:
	print_usage()
	exit()
tasklist_file = "tasklist.txt"
netstat_file = "netstat.txt"
if len(sys.argv) == 2:
	tasklist_file = sys.argv[1]
	netstat_file = sys.argv[2]
with open("netstat.txt") as f:
	netstat_lines = f.readlines()
with open("tasklist.txt") as f:
	tasklist_lines = f.readlines()
pids = {}
for line in tasklist_lines:
	if line.startswith("Image Name"):
		continue
	if line.startswith("==="):
		continue
	if not line.strip():
		continue
	task = line.split()
	pids[task[1]] = task[0]
for line in netstat_lines:
	if line.strip() == "Active Connections":
		print line.rstrip()
		continue
	if not line.strip():
		print line.rstrip()
		continue
	if line.strip().startswith("Proto"):
		print line.rstrip() + "\t\tImage Name"
		continue
	net = line.split()
	pid = net[-1]
	if pid in pids:
		print line.rstrip() + "\t\t" + pids[pid]
	else:
		print line.rstrip() + "\t\t???"
