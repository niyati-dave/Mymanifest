#!/usr/bin/env python
from fabric.api import *

def ntpcon():
        sudo("sed -i 's/server 0.debian.pool.ntp.org iburst/#server 2.debian.pool.ntp.org iburst/g' /etc/ntp.conf")
        sudo("sed -i 's/server 1.debian.pool.ntp.org iburst/#server 2.debian.pool.ntp.org iburst/g' /etc/ntp.conf")
        sudo("sed -i 's/server 2.debian.pool.ntp.org iburst/#server 2.debian.pool.ntp.org iburst/g' /etc/ntp.conf")
        sudo("sed -i 's/server 3.debian.pool.ntp.org iburst/#server 2.debian.pool.ntp.org iburst/g' /etc/ntp.conf")
        sudo("sed -i 's/#server ntp.your-provider.example/server 10.204.105.101/g' /etc/ntp.conf")
        sudo("ntpdate -u 10.204.105.101")
        sudo("service ntp restart")
        sudo("ntpq -p")
