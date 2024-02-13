define add-bootimg
$(if $(call dedup,bootimg-$1),$(eval
$1-kernel ?= kernel
$1-kernelsrc ?= $$(if $$($$($1-kernel)-output),$$($$($1-kernel)-output),$$($$($1-kernel)-out))
$1-kernelsrc := $$($1-kernelsrc)
ifeq ($$(strip $$($1-kernelsrc)),)
$$(error $1-kernelsrc is required)
endif
$1-ramdisk ?= $$(bootimg-ramdisk)
$1-ramdisksrc ?= $$(if $$($$($1-ramdisk)-output),$$($$($1-ramdisk)-output),$$($$($1-ramdisk)-out))
$1-ramdisksrc := $$($1-ramdisksrc)
ifeq ($$(strip $$($1-ramdisksrc)),)
$$(error $1-ramdisksrc is required)
endif
$1-opts ?= $$(bootimg-opts)
$1-cmdline ?= $$(bootimg-cmdline)
$1-out ?= $O/bootimg
$$(call out-dir,$$($1-out))
$$(eval include $$($1-out)/.dir)
$1-output ?= $$($1-out)/$$(if $$($1-variant),$$($1-variant),$1).img
$1-target ?= $1

$$(call clean-if-changed,$$($1-output),opts,$$($1-opts))
$$(call clean-if-changed,$$($1-output),cmdline,$$($1-cmdline))
$$($1-output): $$($1-kernelsrc) $$($1-ramdisksrc)
	$$(call cmd, mkbootimg,,--cmdline '$$($1-cmdline)' $$($1-opts))

.PHONY: $$($1-target)
$$($1-target): $$($1-output)
))
endef

quiet-cmd-mkbootimg = 'MKBOOT   $@'
cmd-mkbootimg = mkbootimg -o $@ --kernel $(word 1,$^) --ramdisk $(word 2,$^)
