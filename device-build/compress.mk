define add-compress
$(if $(call dedup,compress-$1),$(eval
$1-src ?= $$(if $$($2-output),$$($2-output),$$($2-out))
$1-src := $$($1-src)
ifeq ($$(strip $$($1-src)),)
$$(error $1-src is required)
endif
$1-target ?= $1
$1-out ?= $$(call compress-$$($1-algo)-ext,$$($1-src))

$$($1-out): $$($1-src)
	$$(call cmd, $$($1-algo))
))
endef

quiet-cmd-gzip = 'GZIP     $@'
cmd-gzip = gzip -c $(obj) > $@
compress-gzip-ext = $1.gz

quiet-cmd-xz = 'XZ       $@'
cmd-xz = xz -cz $(obj) > $@
compress-xz-ext = $1.xz
