O ?= out
Q ?= @

OUTDIR := $(abspath $O)
HYPDIR := $(abspath $(HYP))

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

ZIGFLAGS:=--prefix-lib-dir '' --prefix-exe-dir '' $(ZIGFLAGS)

define use-zig-toolchain
$(eval
$1: CC=zig cc
$1: CXX=zig c++
$1: LD=zig cc
$1: AR=zig ar
$1: OBJCOPY=zig objcopy
)
endef

define use-host-flags
$(eval
$1: CFLAGS=$(HOSTCFLAGS)
$1: LDFLAGS=$(HOSTLDFLAGS)
$1: ZIGFLAGS=$(HOSTZIGFLAGS)
)
endef

define cmd
$(let cmd obj,cmd-$(strip $1) $(if $2,$2,$<),$(if $($(cmd)),,$(error $(cmd) not defined)) \
$(if $Q,$Q$(if $(quiet-$(cmd)),echo '  '$(quiet-$(cmd));))$(if $(DEPS),echo $@ '<--' $?;) $($(cmd)) $3)
endef

quiet-cmd-cp = 'CP       $@'
cmd-cp = cp $(obj) $@

quiet-cmd-touch = 'TOUCH    $@'
cmd-touch = touch $@

quiet-cmd-gen = 'GEN      $(if $4,$4,$@)'
cmd-gen = true

quiet-cmd-configure = 'CONF     $@'
cmd-configure = cd '$(dir $@)'; $(abspath $(obj)) --srcdir='$(abspath $(dir $(obj)))'

quiet-cmd-makefile = 'MAKE     $@'
cmd-makefile = make -C '$(dir $(obj))' -f '$(notdir $(obj))'

.DELETE_ON_ERROR:
MAKE := $(MAKE) --no-print-directory

$O:
	$(call cmd, mkdir)

define out-dir
$(if $(call dedup,out-dir-$(strip $1)),$(eval $1: $O
	@mkdir -p $$@
$1/.dir:
	@mkdir -p $$(dir $$@); touch $$@
))
endef

define dedup
$(if $($1_DEDUP),,1$(eval $1_DEDUP:=1))
endef

phony-target := PHONY_TARGET
.PHONY: PHONY_TARGET
PHONY_TARGET:

define clean-if-changed
$(let stamp,$(dir $1).$(notdir $1)-$2,$(eval $$(stamp):
	@mkdir -p $$(dir $1)
	$$(file >$$@,cache-$1-$2 := $3)
)$(eval 
include $$(stamp)
ifneq ($$(cache-$1-$2),$3)
$$(shell rm -f $$(stamp) $1)
include $$(stamp)
endif
))
endef
