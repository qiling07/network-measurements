#!/bin/bash

targetIp=$1
sshFile=$2

if [[ -z "${sshFile}" ]]; then
	echo "empty target"
	exit 1
fi

cp ~/.aws/${sshFile} ~/.ssh/
chmod 400 ~/.ssh/${sshFile}
scp -i ~/.ssh/${sshFile} /home/qi/.ssh/Ohio-rsa.pem root@${targetIp}:/root/.ssh/
