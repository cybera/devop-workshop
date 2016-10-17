# DevOp Workshop
This project demonstrates the use of some 'devops' pracitces to create a trivial web site, a drive mirroring service, system monitoring, and a command line tool for managing the system.


## Getting Started

This demonstration requires 
 * An OpenStack account, with access to object storage, and a keypair named 'workshop'
 * A Chef server
 * A Chef workstation, with the knife openstack plugin

For convenience, the 'create-workstation.sh' script will provision an Ubuntu linux server as a Chef workstation, along with the chef-zero server.  After running the script on your server, complete the user configuration by:
 * copying your openstack cloud credentials to /home/ubuntu/.credentials/openrc.sh
 * creating your default ssh identity by copying your 'workshop' openstack ssh keypair to /home/ubuntu/.ssh/id_rsa. 

The workstation includes a utility script to upload chef roles and recipes to the chef server:

    ubuntu@workshop:~$ chef-upload

The demonstration web site can then be created as:
    
    ubuntu@workshop:~$ knife openstack server create --node-name website --run-list "role[website]"



## Devop-Tool commands

### View logs
```
devops logs http
devops logs system
```

### Test http service
```
devops http test
```

### Control http service
```
devops http restart
devops http stop
devops http start
devops http reload
devops http status
```
