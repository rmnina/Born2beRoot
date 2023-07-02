#!/bin/bash

	physical_cpus=$(grep 'physical id' /proc/cpuinfo | uniq | wc -l)
	virtual_cpus=$(grep processor /proc/cpuinfo | uniq | wc -l)
	total_RAM=$(free -h | grep Mem | awk '{print $2}')
	used_RAM=$(free -h | grep Mem | awk '{print $3}')
	RAM_percentage=$(free -k | grep Mem | awk '{printf("%.2f%%"), $3 / $2 * 100}')
	total_disk=$(df -h --total | grep total | awk '{print $2}')
	used_disk=$(df -h --total | grep total | awk '{print $3}')
	disk_percentage=$(df -k --total | grep total | awk '{print $5}')
	CPU_load=$(top -bn1 | grep '^%Cpu' | cut -c 9- | xargs | awk '{printf("%.1f%%"), $1 + $3}')
	last_reboot=$(who -b | awk '{print($3 " " $4)}')
	lvm=$(lsblk | grep lvm | wc -l | awk '{if ($1){print("yes"); exit} else print "no"}')
	connections=$(grep TCP /proc/net/sockstat | awk '{print $3}')
	connected_users=$(who | wc -l)
	ipv4=$(hostname -I | awk '{print $1}')
	MAC=$(ip link show | grep link/ether | awk '{print $2}')
	sudo=$(cat /var/log/sudo/sudo.log | grep -c COMMAND)

	wall "

	 __   __  _______  __    _  ___   _______  _______  ______    ___   __    _  _______ 
	|  |_|  ||       ||  |  | ||   | |       ||       ||    _ |  |   | |  |  | ||       |
	|       ||   _   ||   |_| ||   | |_     _||   _   ||   | ||  |   | |   |_| ||    ___|
	|       ||  | |  ||       ||   |   |   |  |  | |  ||   |_||_ |   | |       ||   | __ 
	|       ||  |_|  ||  _    ||   |   |   |  |  |_|  ||    __  ||   | |  _    ||   ||  |
	| ||_|| ||       || | |   ||   |   |   |  |       ||   |  | ||   | | | |   ||   |_| |
	|_|   |_||_______||_|  |__||___|   |___|  |_______||___|  |_||___| |_|  |__||_______|	
	
	_____________________________________________________________________________________

	#	ARCHITECTURE: $(uname -srvmo)
	#	CPU physical: $physical_cpus
	#	vCPU: $virtual_cpus
	#	Memory Usage: $used_RAM/$total_RAM ($RAM_percentage)
	#	Disk Usage: $used_disk/$total_disk ($disk_percentage)
	#	CPU load: $CPU_load
	#	Last boot: $last_reboot
	#	LVM use: $lvm
	#	Connections TP: $connections ESTABLISHED
	#	User log: $connected_users
	#	Network: IP $ipv4 ($MAC)
	#	Sudo: $sudo cmd 
	_____________________________________________________________________________________"

#		                      /^--^\     /^--^\     /^--^\
#		                      \____/     \____/     \____/
#		                     /      \   /      \   /      \
#		                    |        | |        | |        |
#		                     \__  __/   \__  __/   \__  __/
#		|^|^|^|^|^|^|^|^|^|^|^|^\ \^|^|^|^/ /^|^|^|^|^\ \^|^|^|^|^|^|^|^|^|^|^|^|
#		| | | | | | | | | | | | |\ \| | |/ /| | | | | | \ \ | | | | | | | | | | |
#		| | | | | | | | | | | | / / | | |\ \| | | | | |/ /| | | | | | | | | | | |
#		| | | | | | | | | | | | \/| | | | \/| | | | | |\/ | | | | | | | | | | | |
#		#########################################################################
#		| | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | |
#		| | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | |
#
#		Art by Marcin Glinski (https://www.asciiart.eu/animals/cats)
