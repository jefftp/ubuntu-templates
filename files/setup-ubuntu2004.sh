#! /bin/sh

# Update and upgrade
export DEBIAN_FRONTEND=noninteractive
apt-get -y update
apt-get -y upgrade

# Install additional packages
apt-get -y install open-vm-tools

# Copy multipath config into place
cp -vf /tmp/etc_multipath.conf /etc/multipath.conf
chmod -v 644 /etc/multipath.conf

# Configure VM for VMware Guest Customization
echo "disable_vmware_customization: false" > /etc/cloud/cloud.cfg.d/99-vmware-customization.cfg
