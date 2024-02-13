define add-busybox
$(if $(call dedup,busybox-$1),$(eval
$1-srctree ?= $(HYP)/lib/busybox
$1-target ?= $1
$1-out ?= $O/$$($1-target)
$$(call out-dir, $$($1-out))
$1-output ?= $$($1-out)/busybox
$1-base-config ?= allnoconfig

cmd-$1-make = make -C $$($1-out) KBUILD_SRC=$$(abspath $$($1-srctree)) -f $$(abspath $$($1-srctree)/Makefile) $$(obj)

$$($1-out)/.config: $$($1-config).config $$($1-config).txt $$($1-srctree)/Makefile $$($1-out)/.dir
	$$(call cmd, gen)
	$$(call cmd, $1-make, $$($1-base-config)) >/dev/null 2>&1
	$Qmv $$@ $$@.old
	$Qcat $$< $$@.old > $$@
	$Qrm $$@.old
	$Qsed -f $$(word 2,$$^) -i $$@
	$$(call cmd, $1-make, oldconfig) >/dev/null 2>&1

$$($1-out)/%: $$($1-out)/.config
	$$(call cmd, $1-make,CC='$$(abspath $$(HYP)/device-build/busybox-cc.sh) $$(CC)' LDFLAGS='$$(CFLAGS) $$(LDFLAGS)')

.PHONY: $$($1-target)
$$($1-target): $$($1-output)
))
endef

include $(HYP)/device-build/external.mk
common-busybox-gitmod=busybox
$(call add-git-submod,common-busybox)
