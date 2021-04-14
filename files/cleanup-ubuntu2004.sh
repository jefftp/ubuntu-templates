#! /bin/sh

# Stop services for cleanup
systemctl stop syslog.socket rsyslog.service

# Clear audit logs
if [ -f /var/log/wtmp ]; then
    truncate -s0 /var/log/wtmp
fi

if [ -f /var/log/lastlog ]; then
    truncate -s0 /var/log/lastlog
fi

# Reset cloud-init
cloud-init clean --logs

# Clear machine-id so it is regenerated on next boot
truncate --size=0 /etc/machine-id

# Clear /tmp directories
rm -rfv /tmp/*
rm -rfv /var/tmp/*

# Clean up apt
export DEBIAN_FRONTEND=noninteractive
apt-get -y autoremove
apt-get -y clean

# Remove any existing ssh keys
rm -fv /etc/ssh/ssh_host_*
