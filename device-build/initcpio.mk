define add-initcpio
$(if $(call dedup,initcpio-$1),$(eval
$1-src ?= $1/initcpio.txt
$1-kernel ?= kernel
$1-target ?= $1
$1-out ?= $O/$$($1-target)
$$(call out-dir, $$($1-out))
$1-output := $$($1-out)/out.cpio

$$($1-out)/.deps: $$($1-src) $$($$($1-kernel)-srctree)/usr/gen_initramfs.sh $$($1-out)/.dir
	@cd $$($$($1-kernel)-out); $$(abspath $$($$($1-kernel)-srctree)/usr/gen_initramfs.sh) \
		-o /dev/null -l $$(abspath $$@) $$(abspath $$<) &> /dev/null || true
	@sed -i -e 's/deps_initramfs/$1-deps/' $$(abspath $$@)
include $$($1-out)/.deps

$$($1-output): $$($$($1-kernel)-out)/usr/gen_init_cpio $$($1-src) \
	$$($1-out)/.dir \
	$$($1-deps)
	$$(call cmd, gen-init-cpio,$$($1-src))

.PHONY: $$($1-target)
$$($1-target): $$($1-output)
))
endef

quiet-cmd-gen-init-cpio = 'GEN      $@'
cmd-gen-init-cpio = $< $(obj) > $@
