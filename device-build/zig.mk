define add-zig
$(if $(call dedup,zig-$1),$(eval
$1-srctree ?= $1
$1-target ?= $1
$1-out ?= $O/$$($1-target)
$$(call out-dir, $$($1-out))
$1-cache := $$($1-out)/zig-cache
$$(call out-dir, $$($1-cache))

$1-zigflags := --prefix "$$(abspath $$($1-out))" \
	--cache-dir "$$(abspath $$($1-cache))" \
	$$($1-zigflags)

$$($1-out)/%: ZIGFLAGS+=$$($1-zigflags)

.PHONY: $$($1-target)
$$($1-target): $$($1-out)/.dir $$($1-cache)/.dir
	$$(call cmd,zig-build,$$($1-srctree))

$$($1-out)/%: $$($1-target)
	$$(call cmd,zig-build,$$($1-srctree))
))
endef

quiet-cmd-zig-build = $(if $(V_ZIG),'ZIG      $@')
cmd-zig-build = cd $(obj); zig build $(ZIGFLAGS)
