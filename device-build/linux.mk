define add-kernel
$(if $(call dedup,linux-$1),$(eval
$1-srctree ?= linux
$1-makeflags ?=
$1-llvm ?= $$(LLVM)
$1-target ?= $1
$1-out ?= $O/$$($1-target)
$$(call out-dir, $$($1-out))
$1-arch ?= $$(ARCH)

ifeq ($$($1-arch),)
$$(error $1-arch is required)
endif
ifeq ($$($1-config),)
$$(error $1-config is required)
endif
$1-config-files ?= arch/$$($1-arch)/configs/$$($1-config)
$1-depmod ?= $$(host-kmod-out)/tools/depmod
$1-makeflags := O="$$(realpath $$($1-out))" ARCH="$$($1-arch)" \
	$$(if $$($1-llvm),LLVM=$$($1-llvm)) DEPMOD="$$($1-depmod)" \
	$$($1-makeflags)

quiet-$1-make := 'MAKE     '
cmd-$1-make = $$(MAKE) -C $$($1-srctree) $$($1-makeflags) $$(obj)

.PHONY: $$($1-target) $$($1-target)-all
$$($1-target): $$($1-out)/.config

$$($1-target)-all: $$($1-out)/.config
	$$(call cmd,$1-make,--)

$$($1-out)/.config: $$($1-config-files) $$($1-out)/.dir $$($1-depmod)
	$$(call cmd,$1-make,$$($1-config))
	# make zinstall modules_install dtbs_install \
	# 	ARCH="$$($1-arch)" \
	# 	INSTALL_PATH="$pkgdir"/boot \
	# 	INSTALL_MOD_PATH="$pkgdir" \
	# 	INSTALL_MOD_STRIP=1 \
	# 	INSTALL_DTBS_PATH="$pkgdir"/boot/dtbs
	# rm -f "$pkgdir"/lib/modules/*/build "$pkgdir"/lib/modules/*/source
))
endef

include $(HYP)/device-build/kmod.mk

host-kmod-target := host-kmod
host-kmod-opts := --disable-manpages --disable-test-modules --with-module-directory=/lib/modules --with-zstd --with-xz --with-zlib --without-openssl
$(call add-kmod,host-kmod)
$(call use-host-flags,$(host-kmod-out)/%)
