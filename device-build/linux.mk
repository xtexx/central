define add-kernel
$(if $(call dedup,linux-$1),$(eval
$1-srctree ?= linux
$1-makeflags ?=
$1-llvm ?= $$(LLVM)
$1-target ?= $1
$1-out ?= $O/$$($1-target)
$$(call out-dir, $$($1-out))
$1-install-dir ?= $O/$$($1-target)-dist
$$(call out-dir, $$($1-install-dir))
$1-arch ?= $$(ARCH)

ifeq ($$($1-arch),)
$$(error $1-arch is required)
endif
ifeq ($$($1-config),)
$$(error $1-config is required)
endif
$1-config-files ?= arch/$$($1-arch)/configs/$$($1-config)
$1-depmod ?= $$(host-kmod-out)/tools/depmod
$1-makeflags := O="$$(abspath $$($1-out))" ARCH="$$($1-arch)" \
	$$(if $$($1-llvm),LLVM=$$($1-llvm)) DEPMOD="$$(abspath $$($1-depmod))" \
	$$($1-makeflags)

$1-install := zinstall modules_install \
	INSTALL_PATH='$$(abspath $$($1-install-dir))'/boot \
	INSTALL_MOD_PATH='$$(abspath $$($1-install-dir))' \
	INSTALL_MOD_STRIP=1 \
	INSTALL_DTBS_PATH='$$(abspath $$($1-install-dir))'/boot/dtbs \
	$$($1-install)
$1-instdeps += $$($1-out)/Module.symvers

ifeq ($$($1-arch),arm)
$1-install += dtbs_install
$1-instdeps += $$($1-out)/arch/arm/boot/zImage
endif

quiet-cmd-$1-make = 'MAKE     $$($1-target) $$4'
cmd-$1-make = $$(MAKE) -C $$($1-srctree) $$($1-makeflags) $$(obj)

.PHONY: $$($1-target) $$($1-target)-all $$($1-target)-menuconfig
$$($1-target): $$($1-target)-all
$$($1-target)-all: $$($1-out)/.config
	$$(call cmd,$1-make,--,,all)

$$($1-target)-menuconfig: $$($1-out)/.config
	$$(call cmd,$1-make,menuconfig)
	$@diff $$($1-out)/.config.old $$($1-out)/.config

$$($1-out)/.config: $$($1-config-files) $$($1-out)/.dir
	$$(call cmd,$1-make,$$($1-config))

.PHONY: $$($1-target)-install
$$($1-target)-install: $$($1-depmod)
	$Q$$(MAKE) $$($1-target)-all
	$Q$$(MAKE) $$($1-install-dir)/.hypinststamp

$$($1-install-dir)/.hypinststamp: $$($1-instdeps) $$($1-install-dir)/.dir
	$Qrm -rf $$($1-install-dir)/boot $$($1-install-dir)/lib
	$$(call cmd,$1-make,$$($$($1-target)-install),,install)
	$Qrm -f $$($1-install-dir)/lib/modules/*/build
	$Qtouch $$@
))
endef

include $(HYP)/device-build/kmod.mk

host-kmod-target := host-kmod
host-kmod-opts := --disable-manpages --disable-test-modules --with-module-directory=/lib/modules --with-zstd --with-xz --with-zlib --without-openssl
$(call add-kmod,host-kmod)
$(call use-host-flags,$(host-kmod-out)/%)
