#!/bin/bash

set -e
cd /root/iso_mod/archiso/arch;

cd x86_64
rm airootfs.sfs
mksquashfs squashfs-root airootfs.sfs
md5sum airootfs.sfs > airootfs.md5

cd ..

cd i686
rm airootfs.sfs
mksquashfs squashfs-root airootfs.sfs
md5sum airootfs.sfs > airootfs.md5
