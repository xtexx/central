HYP ?= ../hyperpsi
$(shell [ -e $(HYP) ] || git clone --depth 1 https://git.sr.ht/~xtex/hyperpsi $(HYP))

DEVICE := samsung-klte
ARCH := arm
LLVM := 1
LLVM_TARGET := arm-linux-musleabihf
include $(HYP)/device-build/device.mk
include $(HYP)/device-build/kmod.mk
include $(HYP)/device-build/linux.mk
include $(HYP)/device-build/zig.mk

kmod-opts := --disable-manpages --disable-test-modules \
	--with-module-directory=/lib/modules --without-zstd --without-xz \
	--without-zlib --without-openssl
$(call add-kmod,kmod)

kernel-config := klte_defconfig
kernel-config-files := linux/arch/arm/configs/msm8974_defconfig \
	linux/arch/arm/configs/klte.config \
	linux/arch/arm/configs/klte-hyperpsi.config
$(call add-kernel,kernel)

init-zigflags := --release=small
$(call add-zig,init)

.PHONY: all
all: kernel
