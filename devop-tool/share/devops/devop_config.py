#!/usr/bin/env python

import ConfigParser
from os.path import expanduser
import subprocess
import argparse

def config():
    cfg_fname = ".devop.cfg"
    home = expanduser("~")
    cfg_path = "{}/{}".format(home,cfg_fname)

    config = ConfigParser.RawConfigParser()
    config.read(cfg_path)

    # Check if config already exists
    # and if not, create
    try:
        config.get('server','host')
    except ConfigParser.NoSectionError:
        print("No previous ~/.devop.cfg found. Creating")
        # Create config
        config.add_section('server')
        config.set('server', 'host', 'localhost')
        config.set('server', 'user', 'ubuntu')

        with open('{home}/.devop.cfg'.format(home=home), 'wb') as configfile:
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

