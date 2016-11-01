# DevOp Workshop
This project demonstrates the use of some 'devops' practices to create a trivial web site, a drive mirroring service, system monitoring, and a command line tool for managing the system.

This Repository includes a `start` branch, representing the starting point for the workshop, and the `master` branch, representing the final state of the workshop.  

A set of git patch files are provided in the `start` branch that can be used to bring the `start` branch to the same final state as the `master` branch.  This can be useful to rescue a student that has become lost, or if the amount of typing becomes tedious.  For example:

```git apply patches/chef.cookbooks.lsyncd.attributes.default.rb.patch```



## Accompanying Material

The script and accompanying material for this workshop is provided by this [slide deck][SLIDES].



## Getting Started

This demonstration requires
 * An OpenStack account, with a keypair named 'workshop'
 * A Chef server
 * A Chef workstation, with the [knife openstack plugin][knife-openstack-gem].  This workstation can be created by either
   * Running the 'create-workstation.sh' script to provision a new Ubuntu linux server as a Chef workstation, along with the chef-zero server.  
   * Creating an instance of the public 'devop-workshp' machine image, available on the [Rapid Access Cloud][RAC]


## Workstation Setup

After creating the workstation, complete the workstation configuration by:
 1. Copying your openstack cloud credentials to `/home/ubuntu/.credentials/openrc.sh`
 1. Creating your default ssh identity by copying your 'workshop' openstack ssh key to `/home/ubuntu/.ssh/id_rsa`.
 1. Pull a fresh copy of this repository to the workstation, with either
   * `git clone https://github.com/cybera/devop-workshop.git` or
   * `cd ~/devop-workshop` then `git pull`
 1. Use the provided utility script upload the recipes and roles to the chef-zero server: 

    `ubuntu@workshop:~$ chef-upload`
 1. The demonstration web site can then be created as:

    `ubuntu@workshop:~$ knife openstack server create --node-name website --run-list "role[website]"`



## Workstation Tools

Two sets of command line tools are included:


### Workstation Utilities

These are created by the `create-workstation.sh` script.  They are intended to either be invisible, or to feel like regular Linux command line utilities

 * `chef-upload` - upload all chef recipes and roles
 * `add-identity` - replace the current default ssh id and 'workshop' OpenStack keypair
 * `check_workshop_config` - verifies correct configuration of the workstation. Called automatically at login.
 * `run-chef-zero` - configure and start the Chef-Zero server. Called automatically at login.



### Devop Tools

These command line tools are built using the wonderful [sub][SUB] framework.  The majority of these commands are ready to be used, but a few of them will be built as part of the workshop.  They are intended to feel more like the system maintenance tools an operator would use, or tools to aid a software developer.  In keeping with the spirit of this workshop, a devop would obviously find all of them useful!

#### Configuration

```
~/.devops.cfg (automatically created on first run)
```

```
[defaults]
role = website
```

#### Usage: 

`devops [<command>] [<args>]`

Some useful devops commands are:
 * `backup-db` - Backup the database on the webserver
 * `commands` - List all devops commands
 * `create` - Create demonstration website
 * `disk` - Check disk details for specific roles
 * `haproxy` - Manage local haproxy
 * `http` - Manage remote http server
 * `key` - Manage nova SSH Keys
 * `logs` - View logs on remote system
 * `rsync-key` - Copy ssh key to remote server
 * `server-catalog` - View list of nova and chef servers
 * `ssh` - ssh to an openstack instance

Type `devops help <command>` for information on a specific command.





[knife-openstack-gem]: https://github.com/chef/knife-openstack
[RAC]: https://cloud.cybera.ca
[SUB]: https://github.com/basecamp/sub
[SLIDES]: https://docs.google.com/presentation/d/1Gx4FzVnpoXJfxMCQ3elfUd6njMmTTLrakXW0GoFJ2D8/edit?usp=sharing
