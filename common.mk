#
#  common.mk
#  makecm
#
#  Copyright (C) 2023 Jaider Angarita.
#  All rights reserved.
#
#  This file is part of the makecm project.
#

cross		:= arm-none-eabi-
cc			:= $(cross)gcc
cpp			:= $(cross)gcc -E
cxx			:= $(cross)g++
ld			:= $(cross)gcc
rm			:= rm -rf

vpath %.c $(srcdirs)

objects		:= $(addprefix $(build),$(subst .c,.o,$(sources)))
depends		:= $(addprefix $(build),$(subst .c,.d,$(sources)))

incpath		:= $(addprefix -I,$(incdirs))

mcpuflags	:= -mthumb -mcpu=$(mcpu) -mfloat-abi=$(mfloat)

flags		:= -pipe -Wall -Wextra -Werror \
			   $(mcpuflags) -D$(target) -D$(defines) \
			   $(incpath) -O$(cdebug) \
			   -ffunction-sections -fdata-sections \
			   -ffreestanding \

cflags		:= -std=$(cstd) $(flags)

cxxflags	:= -std=$(cxxstd) $(flags) \
			   -fno-exceptions -fno-rtti

ifeq ($(cdebug),g)
	cflags	+= -g3 -DDEBUG
else
	cflags	+= -g0 -flto
endif

ldflags		+= $(mcpuflags) $(ldlibs) -T$(ldscript) \
			   -pipe \
			   --specs=nano.specs \
			   -Wl,-Map=$(map) \
			   -Wl,--start-group \
			   -Wl,--end-group \
			   -Wl,--gc-sections \
			   -Wl,--print-memory-usage

# .SILENT:

.PHONY: all clean rebuild

all: $(outdirs) $(elf)

clean:
	@echo 'CLEAN'
	-@$(rm) $(outdirs)

rebuild: clean all

$(outdirs):
	@mkdir $@

$(elf): $(objects)
	@echo 'LD	$(notdir $@')
	$(ld) $(ldflags) $^ -o $@

$(build)%.o: %.c
	$(cpp) -MM -MG -MP -MF $(subst .o,.d,$@) -D$(target) $(incpath) $<
	@echo 'CC	$(notdir $<)'
	$(cc) $(cflags) -c $< -o $@

$(build)%.o: %.cpp
	$(cpp) -MM -MG -MP -MF $(subst .o,.d,$@) -D$(target) $(incpath) $<
	@echo 'CC	$(notdir $<)'
	$(cxx) $(cxxflags) -c $< -o $@
