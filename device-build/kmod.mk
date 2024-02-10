define add-kmod
$(if $(call dedup,kmod-$1),$(eval
$1-srctree ?= $(HYP)/lib/kmod
$1-target ?= $1
$1-out ?= $O/$$($1-target)
$$(call out-dir, $$($1-out))

$$($1-out)/%: CFLAGS+=-static -g0 $$($1-cflags)
$$($1-out)/%: LDFLAGS+=-static -flto $$($1-ldflags)

ifneq ($$(call dedup,kmod-conf-$$($1-srctree)),)
$$($1-srctree)/configure: $$($1-srctree)/configure.ac
	$$(call cmd, gen)
	$@touch $$($1-srctree)/libkmod/docs/gtk-doc.make
	$@cd $$($1-srctree); autoreconf -i -s
endif

$$($1-out)/Makefile: $$($1-srctree)/configure $$($1-out)/.dir
	$$(call cmd, configure,,$$($1-opts))

$$($1-out)/tools/%: $$($1-out)/Makefile
	$$(call cmd, makefile,,all)
	@touch $$@

.PHONY: $$($1-target)
$$($1-target): $$($1-out)/tools/kmod
))
endef

include $(HYP)/device-build/external.mk

common-kmod-gitmod=kmod
$(call add-git-submod,common-kmod)
