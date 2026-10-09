# SPDX-License-Identifier: GPL-2.0+
#
# Copyright (C) 2024 Jiaxun yang <jiaxun.yang@flygoat.com>
#

ifeq ($(CONFIG_ARCH_LA64),y)
	ARCH_FLAGS = -target loongarch64-freestanding-none -march=loongarch64 -mtune=loongarch64 -mabi=lp64s
	ARCH_FLAGS += -mld-seq-sa -mrelax -mdiv32 -ffreestanding -mno-lsx -mno-lasx -mstrict-align
	ARCH_FLAGS += -msoft-float -mfpu=none
	ARCH_FLAGS += -z common-page-size=0x100 -z max-page-size=0x100
endif

ifeq ($(CONFIG_$(SPL_)FRAMEPOINTER),y)
	ARCH_FLAGS += -fno-omit-frame-pointer
endif

PLATFORM_CPPFLAGS += $(ARCH_FLAGS)

head-y := arch/loongarch/cpu/start.o

libs-y += arch/loongarch/cpu/
libs-y += arch/loongarch/cpu/$(CPU)/
libs-y += arch/loongarch/lib/

