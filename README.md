firewall-auth-sh
================

IITK firewall auth script which only uses wget, sed and sh. Perfect for running on an OpenWrt router!

The wget binary bundled with OpenWrt doesn't do ssl, which is why we need the wget package (1.2 MiB).

Installation
-------------
Add your username and password in the script, copy to router, install wget, reboot.

```
$ ${EDITOR} firewall-auth.sh
$ scp firewall-auth.sh root@OpenWrt:~
$ scp firewall-auth-init root@OpenWrt:/etc/init.d/firewall-auth
$ ssh root@OpenWrt
# opkg update
# opkg install wget
# /etc/init.d/firewall-auth enable
# reboot
```
