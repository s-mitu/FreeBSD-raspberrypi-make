#!/bin/sh

#webcamd
echo  cuse_load="YES" >> /boot/loader.conf
echo webcamd_enable="YES" > /etc/rc.conf.d/webcamd
pw groupmod webcamd -m  freebsd
