# DevOp Workshop
This project demonstrates the use of some 'devops' practices to create a trivial web site, a drive mirroring service, system monitoring, and a command line tool for managing the system.


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

### Configuration

~/.devops.cfg (automatically created on first run)
```
[defaults]
role = website
```

### Create website
```
devops create website
```

### View logs
```
devops logs http
devops logs system
```

### Manage (remote) http service
```
devops http restart
devops http stop
devops http start
devops http reload
devops http status
devops http test
```

### Manage (local) haproxy service
```
devops haproxy install
devops haproxy config
devops haproxy restart
devops haproxy stop
devops haproxy start
devops haproxy reload
devops haproxy status
devops haproxy test
```

### View server catalog
```
devops server-catalog
```

### SSH via nova instance name (or ID)
```
devops ssh website
```

### Manage nova SSH keys
```
devops key new
devops key list
devops key upload
devops key replace
```
