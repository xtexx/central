define add-squashfs
$(if $(call dedup,squashfs-$1),$(eval
ifeq ($$(strip $$($1-src)),)
$$(error $1-src is required)
endif
$1-opts ?=
$1-out ?= $O/$1
$$(call out-dir,$$($1-out))
$1-output ?= $$($1-out)/$1.sqfs
$1-out-fs ?= $$($1-out)/fs
$$(call out-dir,$$($1-out-fs))
$1-target ?= $1

$$(call clean-if-changed,$$($1-output),opts,$$($1-opts))
$$(call clean-if-changed,$$($1-output),src,$$($1-src))
$$($1-output): $$($1-out)/.dir $$($1-out-fs)/.dir \
		$$(addprefix $$($1-out-fs),$$(foreach src,$$($1-src),$$(word 1,$$(subst ::, ,$$(src)))))
	$$(call cmd, mksquashfs,$$($1-out-fs),$$($1-opts))

.PHONY: $$($1-target)
$$($1-target): $$($1-output)
))
$(foreach src,$($1-src),$(let ssrc,$(subst ::, ,$(src)),$(let dest source cmdtype dep,$(ssrc),$(eval
$($1-out-fs)$(dest): $(if $(dep),$(dep),$(source)) $($1-out-fs)/.dir
	$$Qmkdir -p $$(dir $$@)
	$$(call cmd,$(if $(cmdtype),$(cmdtype),cp),$(source))
))))
endef

quiet-cmd-mksquashfs = 'MKSQFS   $@'
cmd-mksquashfs = mksquashfs $(obj) $@ \
	-comp xz -all-root -pseudo-override -wildcards -quiet -no-recovery -noappend \
	-action "exclude @ name(.dir)"
