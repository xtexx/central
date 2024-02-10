define add-kmod
$(if $(call dedup,kmod-$1),$(eval
$1_SRCTREE ?= $(HYP)/lib/kmod
$1_TARGET ?= kmod
$1_OUT ?= $O/$$($1_TARGET)
$$(call out-dir, $$($1_OUT))

$$($1_OUT)/%: CFLAGS+=-static $$($1_CFLAGS)
$$($1_OUT)/%: LDFLAGS+=-static -flto $$($1_LDFLAGS)

ifneq ($$(call dedup,kmod-conf-$$($1_SRCTREE)),)
$$($1_SRCTREE)/configure: $$($1_SRCTREE)/configure.ac
	$$(call cmd, gen)
	$@touch $$($1_SRCTREE)/libkmod/docs/gtk-doc.make
	$@cd $$($1_SRCTREE); autoreconf -i -s
endif

$$($1_OUT)/Makefile: $$($1_SRCTREE)/configure $$($1_OUT)/.dir
	$$(call cmd, configure,,$$(zig-toolchain) $$($1_OPTS))

$$($1_OUT)/tools/%: $$($1_OUT)/Makefile
	$$(call cmd, makefile,,all)

.PHONY: $$($1_TARGET)
$$($1_TARGET): $$($1_OUT)/tools/kmod
))
endef

include $(HYP)/device-build/external.mk

COMMON_KMOD_GITMOD=kmod
$(call add-git-submod,COMMON_KMOD)
