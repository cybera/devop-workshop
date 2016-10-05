default['lsyncd']['conf_d'] = '/etc/lsyncd/conf.d'
default['lsyncd']['log_file'] = '/var/log/lsyncd.log'
default['lsyncd']['status_file'] = '/var/log/lsyncd-status.log'

default[:lsyncd][:exclude] = {
    "temp" => true,
    "**/*.tmp" => true
}

default[:lsyncd][:rsync] = {
    "rysnc" => {
        :enabled => true,
        :source => "/tmp/foo",
        :target => "/tmp/bar"
    }
}
