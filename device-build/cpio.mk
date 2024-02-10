define add-cpio
$(if $(call dedup,cpio-$1),$(eval
$1-srctree ?= $(HYP)/lib/cpio
$1-target ?= $1
$1-out ?= $O/$$($1-target)
$$(call out-dir, $$($1-out))
$1-opts := --enable-rpath $$($1-opts)

$$($1-out)/%: CFLAGS+=-static -g0 $$($1-cflags)
$$($1-out)/%: LDFLAGS+=-static -flto $$($1-ldflags)

ifneq ($$(call dedup,cpio-conf-$$($1-srctree)),)
$$($1-srctree)/configure: $$($1-srctree)/configure.ac
	$$(call cmd, gen)
	$@cd $$($1-srctree); ./bootstrap
endif

$$($1-out)/Makefile: $$($1-srctree)/configure $$($1-out)/.dir
	$$(call cmd, configure,,$$($1-opts))

$$($1-out)/src/%: $$($1-out)/Makefile
	$$(call cmd, makefile,,all)

.PHONY: $$($1-target)
$$($1-target): $$($1-out)/src/cpio
))
endef

include $(HYP)/device-build/external.mk
common-cpio-gitmod=cpio
$(call add-git-submod,common-cpio)
