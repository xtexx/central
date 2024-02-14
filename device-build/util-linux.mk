define add-util-linux
$(if $(call dedup,util-linux-$1),$(eval
$1-srctree ?= $(HYP)/lib/util-linux
$1-target ?= $1
$1-out ?= $O/$$($1-target)
$$(call out-dir, $$($1-out))

$$($1-out)/%: CFLAGS+=-static -g0 $$($1-cflags)
$$($1-out)/%: LDFLAGS+=-static -flto $$($1-ldflags)

ifneq ($$(call dedup,util-linux-conf-$$($1-srctree)),)
$$($1-srctree)/configure: $$($1-srctree)/configure.ac
	$$(call cmd, autogen-sh)
endif

$$($1-out)/Makefile: $$($1-srctree)/configure $$($1-out)/.dir
	$$(call cmd, configure,,$$($1-opts))

$$($1-out)/%: $$($1-out)/Makefile
	$$(call cmd, makefile,,$*)
	@touch $$@

.PHONY: $$($1-target)
$$($1-target): $$($1-out)/--
))
endef

include $(HYP)/device-build/external.mk

common-util-linux-gitmod=util-linux
$(call add-git-submod,common-util-linux)
