default['lsyncd']['conf_d'] = '/etc/lsyncd/conf.d'
default['lsyncd']['log_file'] = '/var/log/lsyncd.log'
default['lsyncd']['status_file'] = '/var/log/lsyncd-status.log'

default[:lsyncd][:exclude] = {
    "temp" => true,
    "**/*.tmp" => true
}

default[:lsyncd][:source] = "/home/ubuntu/rsync-source"
default[:lsyncd][:destination] = "/home/ubuntu/rsync-destination"

default[:lsyncd][:rsync] = {
    "rsync" => {
        :enabled => false,
        :source => node[:lsyncd][:source],
        :target => node[:lsyncd][:destination]
    },
    "rsyncssh" =>{
        :enabled => true,
        :source => node[:lsyncd][:source],
        :target => node[:lsyncd][:destination],
        :host => "workshop"
    }
}

default[:lsyncd][:identity_file] = "/home/ubuntu/.ssh/rsync.pem"
