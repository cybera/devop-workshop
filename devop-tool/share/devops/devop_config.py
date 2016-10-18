#!/usr/bin/env python

import ConfigParser
from os.path import expanduser
import subprocess
import shlex
import argparse

def config():
    cfg_fname = ".devops.cfg"
    home = expanduser("~")
    cfg_path = "{}/{}".format(home,cfg_fname)

    config = ConfigParser.RawConfigParser()
    config.read(cfg_path)

    # Check if config already exists
    # and if not, create
    try:
        config.get('defaults','role')
    except ConfigParser.NoSectionError:
        print("No previous {} found. Creating".format(cfg_path))
        # Create config
        config.add_section('defaults')
        config.set('defaults', 'role', 'website')

        with open('{}'.format(cfg_path), 'wb') as configfile:
            config.write(configfile)

    return config

def devop_args():
    parser = argparse.ArgumentParser()

    parser.add_argument("-r", "--role", dest="role",
                      help="role for knife", metavar="ROLE")

    return parser


def ssh_cmd(shell_cmd, role=None, host=None):

    if host == 'local':
        # Local command
        command = '{cmd}'.format(cmd=shell_cmd)
    elif role is None:
        # default to website role if none specified
        command = 'knife ssh "role:website" -a ipaddress "{cmd}"'.format(cmd=shell_cmd)
    else:
        # role specific command
        command = 'knife ssh "role:{role}" -a ipaddress "{cmd}"'.format(role=role,cmd=shell_cmd)

    print("{}\n----------------------".format(command))

    process = subprocess.Popen(shlex.split(command), stdout=subprocess.PIPE)

    while True:
        output = process.stdout.readline()
        if output == '' and process.poll() is not None:
            break
        if output:
            print output.strip()

    rc = process.poll()


