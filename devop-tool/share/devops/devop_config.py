#!/usr/bin/env python

import ConfigParser
from os.path import expanduser

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
