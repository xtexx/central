O ?= out
Q ?= @

OUTDIR := $(realpath $O)
HYPDIR := $(realpath $(HYP))

ifneq ($(LLVM),)
ifneq ($(filter %/,$(LLVM)),)
LLVM_PREFIX := $(LLVM)
else ifneq ($(filter -%,$(LLVM)),)
LLVM_SUFFIX := $(LLVM)
endif
CC:=$(LLVM_PREFIX)clang$(LLVM_SUFFIX)
CXX:=$(LLVM_PREFIX)clang++$(LLVM_SUFFIX)
LD:=$(LLVM_PREFIX)ld.lld$(LLVM_SUFFIX)
AR:=$(LLVM_PREFIX)llvm-ar$(LLVM_SUFFIX)
STRIP:=$(LLVM_PREFIX)llvm-strip$(LLVM_SUFFIX)
NM:=llvm-nm
OBJCOPY:=llvm-objcopy
OBJDUMP:=llvm-objdump
READELF:=llvm-readelf
CFLAGS:=-target $(LLVM_TARGET) $(CFLAGS)
endif
HOSTCC?=$(CC)
HOSTCXX?=$(CXX)
HOSTAR?=$(AR)
HOSTLD?=$(LD)
export CC CXX LD AR NM STRIP OBJCOPY OBJDUMP READELF HOSTCC HOSTCXX HOSTAR HOSTLD

CFLAGS:=-Os $(CFLAGS)
LDFLAGS:=-Wl,-z,relro,-z,now $(LDFLAGS)
export CFLAGS LDFLAGS

zig-toolchain=CC='zig cc' CXX='zig c++' LD='zig cc' AR='zig ar' OBJCOPY='zig objcopy'
define use-host-flags
$(eval
$1: CFLAGS=$(HOSTCFLAGS)
$1: LDFLAGS=$(HOSTLDFLAGS)
)
endef

define cmd
$(let cmd obj,cmd_$(strip $1) $(if $2,$2,$<),$(if $($(cmd)),,$(error $(cmd) not defined)) \
$(if $Q,,echo Deps $? were changed; ) \
$(if $Q,$Q$(if $(quiet_$(cmd)),echo '  '$(quiet_$(cmd));)) $($(cmd)) $3)
endef

quiet_cmd_cp = 'CP       $@'
cmd_cp = cp $(obj) $@

quiet_cmd_touch = 'TOUCH    $@'
cmd_touch = touch $@

quiet_cmd_gen = 'GEN      $@'
cmd_gen = true

quiet_cmd_configure = 'CONF     $@'
cmd_configure = cd '$(dir $@)'; $(abspath $(obj)) --srcdir='$(abspath $(dir $(obj)))'

quiet_cmd_makefile = 'MAKE     $@'
cmd_makefile = make -C '$(dir $(obj))' -f '$(notdir $(obj))'

.DELETE_ON_ERROR:
.ONESHELL:

$O:
	$(call cmd, mkdir)

define out-dir
$(eval $1: $O
	@mkdir -p $$@
$1/.dir:
	@mkdir -p $$(dir $$@); touch $$@)
endef

define dedup
$(if $($1_DEDUP),,1$(eval $1_DEDUP=1))
endef
