define add-git-submod
$(if $(call dedup,git-submod-$1),$(eval
$1_GITDIR ?= $(HYP)
$1_GITMOD ?= $1
$1_MODDIR ?= lib/$$($1_GITMOD)
$1_SRCTREE ?= $$($1_GITDIR)/$$($1_MODDIR)
$1_GITHEAD ?= $$($1_GITDIR)/.git/modules/$$($1_GITMOD)/HEAD

quiet_cmd_submod-$1='SYNC     $1'
cmd_submod-$1=git -C $$($1_GITDIR) submodule update --init --recommend-shallow --recursive --single-branch -- $$($1_MODDIR)

$$($1_GITHEAD): $$($1_GITDIR)/.gitmodules
	$$(call cmd,submod-$1)
	@touch $$@

$$($1_SRCTREE)/%: $$($1_GITHEAD)
	$$(call cmd,submod-$1)
	@touch $$@

.PHONY: sync-$$($1_GITMOD)
sync-$$($1_GITMOD):
	$$(call cmd,submod-$1)
))
endef
