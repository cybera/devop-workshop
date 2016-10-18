#!/usr/bin/env python

import ConfigParser
from os.path import expanduser
import subprocess
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

    print("{0}\n----------------------".format(shell_cmd))

    if host == 'local':
        # Local command
        print subprocess.check_output(
            '{cmd}'.format(cmd=shell_cmd),
            stderr=subprocess.STDOUT,
            shell=True)

    elif role is None:
        print subprocess.check_output(
            'knife ssh "role:website" -a ipaddress "{cmd}"'.format(cmd=shell_cmd),
            stderr=subprocess.STDOUT,
            shell=True)
    else:
        print subprocess.check_output(
            'knife ssh "role:{role}" -a ipaddress "{cmd}"'.format(role=role,cmd=shell_cmd),
            stderr=subprocess.STDOUT,
            shell=True)

