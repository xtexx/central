define add-git-submod
$(if $(call dedup,git-submod-$1),$(eval
$1-gitdir ?= $(HYP)
$1-gitmod ?= $1
$1-moddir ?= lib/$$($1-gitmod)
$1-srctree ?= $$($1-gitdir)/$$($1-moddir)
$1-githead ?= $$($1-gitdir)/.git/modules/$$($1-gitmod)/HEAD

quiet-cmd-submod-$1='SYNC     $1'
cmd-submod-$1=git -C $$($1-gitdir) submodule sync --recursive -- $$($1-moddir); \
	git -C $$($1-gitdir) submodule update --init --recommend-shallow --recursive --single-branch -- $$($1-moddir); \
	$$($1-postsync)

$$($1-githead): $$($1-gitdir)/.gitmodules
	$$(call cmd,submod-$1)
	@touch $$@

$$($1-srctree)/%: $$($1-githead)
	$$(call cmd,submod-$1)
	@touch $$@

.PHONY: sync-$$($1-gitmod)
sync-$$($1-gitmod):
	$$(call cmd,submod-$1)
))
endef
