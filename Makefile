HYP ?= ../hyperpsi
$(shell [ -e $(HYP) ] || git clone --depth 1 --recurse-submodules --shallow-submodules https://git.sr.ht/~xtex/hyperpsi $(HYP))

DEVICE := samsung-klte
ARCH := arm
LLVM := 1
LLVM_TARGET := arm-linux-musleabihf
include $(HYP)/device-build/device.mk
include $(HYP)/device-build/kmod.mk
include $(HYP)/device-build/linux.mk

KMOD_OPTS := --disable-manpages --disable-test-modules \
	--with-module-directory=/lib/modules --without-zstd --without-xz \
	--without-zlib --without-openssl
$(call add-kmod,KMOD)

KERNEL_CONFIG := klte_defconfig
KERNEL_CONFIG_FILES := linux/arch/arm/configs/msm8974_defconfig \
	linux/arch/arm/configs/klte.config \
	linux/arch/arm/configs/klte-hyperpsi.config
$(call add-kernel,KERNEL)

.PHONY: all
all: kernel
