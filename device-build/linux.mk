define add-kernel
$(if $(call dedup,linux-$1),$(eval
$1_SRCTREE ?= linux
$1_MAKEFLAGS ?=
$1_LLVM ?= $$(LLVM)
$1_TARGET ?= kernel
$1_OUT ?= $O/$$($1_TARGET)
$$(call out-dir, $$($1_OUT))
$1_ARCH ?= $$(ARCH)

ifeq ($$($1_ARCH),)
$$(error $1_ARCH is required)
endif
ifeq ($$($1_CONFIG),)
$$(error $1_CONFIG is required)
endif
$1_CONFIG_FILES ?= arch/$$($1_ARCH)/configs/$$($1_CONFIG)

$1_MAKEFLAGS := O="$$(realpath $$($1_OUT))" ARCH="$$($1_ARCH)" \
	$$(if $$($1_LLVM),LLVM=$$($1_LLVM)) DEPMOD="$$(HOST_KMOD_OUT)/tools/depmod" \
	$$($1_MAKEFLAGS)

quiet_$1_make := 'MAKE     '
cmd_$1_make = $$(MAKE) -C $$($1_SRCTREE) $$($1_MAKEFLAGS) $$(obj)

.PHONY: $$($1_TARGET) $$($1_TARGET)-all
$$($1_TARGET): $$($1_OUT)/.config

$$($1_TARGET)-all: $$($1_OUT)/.config
	$$(call cmd,$1_make,--)

$$($1_OUT)/.config: $$($1_CONFIG_FILES) $$($1_OUT)/.dir
	$$(call cmd,$1_make,$$($1_CONFIG))
	# make zinstall modules_install dtbs_install \
	# 	ARCH="$($1_ARCH)" \
	# 	INSTALL_PATH="$pkgdir"/boot \
	# 	INSTALL_MOD_PATH="$pkgdir" \
	# 	INSTALL_MOD_STRIP=1 \
	# 	INSTALL_DTBS_PATH="$pkgdir"/boot/dtbs
	# rm -f "$pkgdir"/lib/modules/*/build "$pkgdir"/lib/modules/*/source
))
endef

include $(HYP)/device-build/kmod.mk

HOST_KMOD_TARGET := host-kmod
HOST_KMOD_OPTS := --disable-manpages --disable-test-modules --with-module-directory=/lib/modules --with-zstd --with-xz --with-zlib --without-openssl
$(call add-kmod,HOST_KMOD)
$(call use-host-flags,$(HOST_KMOD_OUT)/%)
