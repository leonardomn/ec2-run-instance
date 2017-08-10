#!/bin/bash

#I think using like this will be more simple than build with others tools.

#It's immportant to understand in this case i'm using a .pem key, this key is the same i have a lot of server running, so i hope you can understand
#i can't share this, so in this servers bellow you can user a password i will be send into your email.

#number of servers to create
num_servers=1 #$3

#size of server you want to create
server_size=t2.nano #$4

#Execute command to create server (this is using a paid account, to full test need to change you configurations)
echo Executing run instance...
aws ec2 run-instances --image-id ami-116d857a --count $num_servers --instance-type $server_size --key-name rds --subnet-id subnet-bb0c61cc > server.cfg

#We need to wait server be running, somethimes is more than 30 seconds, so wait this time is only for safety
echo Sleeping...... We need server initialize...
sleep 60

#This clean the result of file cfg to get only the instace id to get IP, we need to do that because ip can delay a little bit to return
echo Working on result files...
cat server.cfg | awk '/"InstanceId":/ {print $2}' > instanceidfile.cfg
tr -d '",' < instanceidfile.cfg > instanceid.cfg
rm instanceidfile.cfg

#Now we need to consult server and get the IP Address formating to a know format
echo Cleaning ip address from files...
aws ec2 describe-instances --instance-ids "$(< instanceid.cfg)" > serverdata.cfg
cat serverdata.cfg | awk '/"PublicIpAddress":/ {print $2}' > ipfile.cfg
tr -d '",' < ipfile.cfg > ip.cfg
rm serverdata.cfg instanceid.cfg ipfile.cfg


#This is a example if you want to install or send files in the same script to automate packages installs.

#upload the site file to server
#scp app/hello.py admin@"$(< ip.cfg)":.

#update server, install packs and run the webserver. 
#ssh admin@"$(< ip.cfg)" << SCRIPT
#	sudo apt-get update
#	sudo apt-get install python-virtualenv -y
#	virtualenv venv
#	. venv/bin/activate
#	pip install Flask
#	export FLASK_APP=hello.py
#	flask run --host=0.0.0.0
#SCRIPT