systemimg-src += /init::out/loader/loader
systemimg-src += /etc/hypinit.config::init/hypinit.config

systemimg-src += /usr/bin/kmod::$(kmod-out)/tools/kmod
systemimg-opts += -p '/usr/bin/depmod s 777 0 0 /usr/bin/kmod'
systemimg-opts += -p '/usr/bin/lsmod s 777 0 0 /usr/bin/kmod'
systemimg-opts += -p '/usr/bin/insmod s 777 0 0 /usr/bin/kmod'
systemimg-opts += -p '/usr/bin/rmmod s 777 0 0 /usr/bin/kmod'
systemimg-opts += -p '/usr/bin/modinfo s 777 0 0 /usr/bin/kmod'
systemimg-opts += -p '/usr/bin/modprobe s 777 0 0 /usr/bin/kmod'

systemimg-src += /lib/modules::$(kernel-install-dir)/lib/modules::cp::$(kernel-install-dir)/.hypinststamp

# dir /etc 755 0 0
# file /etc/hypinit.config init/hypinit.config 644 0 0
# file /etc/mdev.conf init/mdev.conf 644 0 0

# dir /bin 755 0 0
# slink /bin/sh /usr/bin/busybox 777 0 0
# dir /usr 755 0 0
# dir /usr/bin 755 0 0
# file /usr/bin/busybox out/busybox-init/busybox 777 0 0
# file /usr/bin/blkid out/util-linux-init/blkid 777 0 0

# dir /lib 755 0 0
# dir /lib/mdev 755 0 0
# file /lib/mdev/persistent-storage ../hyperpsi/lib/mdev-conf/persistent-storage 755 0 0
