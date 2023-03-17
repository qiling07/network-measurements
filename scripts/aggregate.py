import sys
import ipaddress as ipad
import os

target8 = ipad.ip_network(sys.argv[1])
levelN = int(sys.argv[2])


basic_cnt = 0
all_cnt = 0
for subnetN in list(target8.subnets(new_prefix=levelN)) :
	basic = set()
	all = set()
	for subsubnet16 in list(subnetN.subnets(new_prefix=16)) :
		fileName = "/root/network-measurements/results/" + str(subsubnet16.supernet(new_prefix=12)).replace("/", "_") + "/" + str(subsubnet16).replace("/", "_") + ".links"
		if not os.path.isfile(fileName) :
			continue
		with open(fileName, 'r') as inFile :
			for line in inFile :
				line = line.strip().split()
				if line[0] == "basicLinks" :
					basic.update(line[1:])
				elif line[0] == "allLinks" :
					all.update(line[1:])
	if len(all) == 0:
		print(subnetN)
	else :
		basic_cnt += len(basic)
		all_cnt += len(all)

print(str(target8) + " with level " + str(levelN), basic_cnt / all_cnt)

