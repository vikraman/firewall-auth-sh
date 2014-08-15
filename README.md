firewall-auth-sh
================

IITK firewall auth script for fortigate which only uses curl, sed and sh.
Perfect for running on an OpenWrt router!

The fortigate gateway works over HTTPS, which is why we need curl with ssl
support. With libcurl linked against polarssl, all the packages fit nicely into
the 4MiB filesystem of most TP-Link routers.

Installation
-------------
Add your username and password in the script, copy to router, reboot.

```
$ ${EDITOR} firewall-auth.sh
$ scp firewall-auth.sh root@OpenWrt:~
$ scp firewall-auth-init root@OpenWrt:/etc/init.d/firewall-auth
$ ssh root@OpenWrt
# /etc/init.d/firewall-auth enable
# reboot
```
