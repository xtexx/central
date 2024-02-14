HYP ?= ../hyperpsi
$(shell [ -e $(HYP) ] || git clone --depth 1 https://git.sr.ht/~xtex/hyperpsi $(HYP))

DEVICE := samsung-klte
ARCH := arm
LLVM := 1
LLVM_TARGET := arm-linux-musleabihf
include $(HYP)/device-build/device.mk
include $(HYP)/device-build/bootimg.mk
include $(HYP)/device-build/busybox.mk
include $(HYP)/device-build/compress.mk
include $(HYP)/device-build/cpio.mk
include $(HYP)/device-build/initcpio.mk
include $(HYP)/device-build/kmod.mk
include $(HYP)/device-build/linux.mk
include $(HYP)/device-build/mdev-conf.mk
include $(HYP)/device-build/squashfs.mk
include $(HYP)/device-build/util-linux.mk
include $(HYP)/device-build/zig.mk

.PHONY: all
all: kernel

kmod-opts := --disable-manpages --disable-test-modules \
	--with-module-directory=/lib/modules --without-zstd --without-xz \
	--without-zlib --without-openssl
$(call add-kmod,kmod)
$(call use-zig-toolchain,$(kmod-out)/%)

kernel-config := klte_defconfig
kernel-config-files := linux/arch/arm/configs/msm8974_defconfig \
	linux/arch/arm/configs/klte.config \
	linux/arch/arm/configs/klte-hyperpsi.config
$(call add-kernel,kernel)

init-zigflags := --release=small
$(call add-zig,init)

busybox-init-config := init/busybox
$(call add-busybox,busybox-init)
$(call use-zig-toolchain,$(busybox-init-out)/%)

util-linux-init-opts := --disable-all-programs --disable-nls \
	--enable-static --enable-libblkid --enable-blkid
$(call add-util-linux,util-linux-init)
$(call use-zig-toolchain,$(util-linux-init-out)/%)

initcpio-src := init/initcpio.txt
$(call add-initcpio,initcpio)

initcpio-xz-algo := xzkern
$(call add-compress,initcpio-xz,initcpio)

kernel-klte-dtb := qcom-msm8974pro-samsung-klte
$(call add-kernel-dtb,kernel-klte)
kernel-kltechn-dtb := qcom-msm8974pro-samsung-kltechn
$(call add-kernel-dtb,kernel-kltechn)

bootimg-ramdisk := initcpio-xz
bootimg-cmdline := msm.vram=192m msm.allow_vram_carveout=1
bootimg-opts := --base 0x00000000 --kernel_offset 0x00008000 \
	--ramdisk_offset 0x02000000 --second_offset 0x00f00000 \
	--tags_offset 0x01e00000 --pagesize 2048

bootimg-klte-variant := klte
bootimg-klte-kernel := kernel-klte
$(call add-bootimg,bootimg-klte)
bootimg-kltechn-variant := kltechn
bootimg-kltechn-kernel := kernel-kltechn
$(call add-bootimg,bootimg-kltechn)

loader-zigflags := --release=fast
$(call add-zig,loader)

busybox-config := loader/busybox
busybox-base-config := defconfig
$(call add-busybox,busybox)
$(call use-zig-toolchain,$(busybox-out)/%)

include loader/systemimg.mk
$(call add-squashfs,systemimg)
