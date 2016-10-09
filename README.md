# rfyimaging
Scripts and configuration files to set up a dnsmasq + darkhttpd TFTP Arch Linux imaging server for [Reboot for Youth](http://www.rebootforyouth.org/)

## First time setup

* Install required packages, including squashfs-tools, dnsmasq, and darkhttpd.

* Create the directory where darkhttpd will serve the files (in this case, `/srv/pxe/arch`).

* Mount your Arch Linux ISO and copy over all the files to the directory where darkhttpd will serve the files from.

* Edit `arch_install.sh` to have the desired root password, username, and password combination, along with any other desired packages or configuration.

* Change into the directory with the x86_64 squashfs file (in this case `/srv/pxe/arch/arch/x86_64`) and run `unsquashfs airootfs.sfs`.

* Do the same for the directory with the i686 squashfs file (in this case `/srv/pxe/arch/arch/i686`)

* (Makes updating the script much easier) hard link (in this case, `/srv/pxe/arch/arch/i686/squashfs-root/root/arch_install.sh` and `/srv/pxe/arch/arch/x86_64/squashfs-root/root/arch_install.sh`) to `arch_install.sh` in the git repository.

**OR**

* Copy `arch_install.sh` into the `squashfs_root/` directory for each platform.

* Edit `rebuild_squashfs.sh` to have the correct directories.

* Run `./rebuild_squashfs.sh`

* Edit `dnsmasq.conf` to have the correct network configuration (subnet is typically `192.168.1.x`)

* (Makes updating config much easier) hard link `/etc/dnsmasq.conf` to `dnsmasq.conf` in the git repository

**OR**

* Copy over `dnsmasq.conf` to `/etc/dnsmasq.conf` .

* Run `./start_pxe.sh` to start the server.
